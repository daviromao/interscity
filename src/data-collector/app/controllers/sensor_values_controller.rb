# frozen_string_literal: true

class SensorValuesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_sensor_values,
                only: %i[resources_data resource_data]
  before_action :set_sensor_values_last,
                only: %i[resources_data_last resource_data_last resources_search]
  before_action :set_specific_resource,
                only: %i[resource_data resource_data_last]
  before_action :filter_by_uuids, only: %i[resources_data resources_data_last resources_search]
  before_action :filter_by_date, :filter_by_capabilities, :filter_by_value

  def set_sensor_values
    @sensor_values = SensorValue.all

    paginate
  end

  def set_sensor_values_last
    @sensor_values = LastSensorValue.all

    paginate
  end

  def paginate
    # Validate 'limit' and 'start' parameters (they must be positive integers)
    # and asserts that limit is less than or equal to 1000
    limit = params[:limit] || '1000'
    start = params[:start] || '0'
    limit = '1000' unless limit.to_i <= 1000

    [limit, start].each do |arg|
      next if arg.nil? || arg.positive_int?

      render json: {
        error: 'Bad Request: pagination args not valid'
      },
             status: :bad_request
      break # Prevents DoubleRenderError
    end

    @sensor_values = @sensor_values.limit(limit) unless limit.nil?
    @sensor_values = @sensor_values.offset(start) unless start.nil?
  end

  def filter_by_uuids
    uuids = params[:uuids]
    return if uuids.nil? || !uuids.is_a?(Array)

    @sensor_values = @sensor_values.where(:uuid.in => uuids)
  end

  def filter_by_date
    @start_date = params[:start_date]
    @end_date = params[:end_date]

    unless @start_date.nil?
      @sensor_values = @sensor_values
                       .where(:date.gte => DateTime.parse(@start_date))
    end
    unless @end_date.nil?
      @sensor_values = @sensor_values
                       .where(:date.lte => DateTime.parse(@end_date))
    end
  rescue StandardError
    render json: { error: 'Bad Request: resource not found' }, status: :bad_request
  end

  def filter_by_capabilities
    capabilities_name = params[:capabilities]
    return unless capabilities_name

    @sensor_values = @sensor_values.where(:capability.in => capabilities_name)
  end

  def filter_by_value
    return unless params[:matchers]

    dynamic_values = params[:matchers].to_unsafe_h
    filters = create_filters(dynamic_values)
    @sensor_values = @sensor_values.where(filters)
  end

  def concat_value(sensor_trim, cap_values)
    if sensor_trim.nil?
      sensor_trim = cap_values
    else
      sensor_trim |= cap_values
    end
    sensor_trim
  end

  # Return all resources with all their capabilities. Finally, each capability
  # has all the historical values associated with it.
  # @note http://localhost:3000/resources/data
  def resources_data
    generate_response
  rescue StandardError => e
    render json: { error: 'Internal server error: ' + e.message }, status: :internal_server_error
  end

  def resource_data
    generate_response
  rescue StandardError => e
    render json: { error: 'Internal server error: ' + e.message }, status: :internal_server_error
  end

  def resources_data_last
    resources_data
  end

  def resource_data_last
    resources_data_last
  end

  def resources_search
    render json: { resources: @sensor_values.pluck(:uuid) }
  end

  private

  def set_specific_resource
    # params[:uuid] gets from the uri, while sensor_value_params gets
    # it from the json sent
    @sensor_values = @sensor_values.where(uuid: params[:uuid])
    raise Mongoid::Errors::DocumentNotFound.new(LastSensorValue, uuid: params['uuid']) if @sensor_values.blank?
  rescue Mongoid::Errors::DocumentNotFound
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def generate_response
    resources = {}

    @sensor_values.each do |value|
      collected = {}

      value.dynamic_attributes.each do |attribute, attribute_value|
        collected[attribute] = attribute_value
      end
      resource = resources[value.uuid] || {}
      capabilities = resource['capabilities'] || {}
      capability = capabilities[value.capability] || []
      capability << collected

      capabilities[value.capability] = capability
      resource['uuid'] = value.uuid
      resource['capabilities'] = capabilities
      resources[value.uuid] = resource
    end
    render json: { resources: resources.values }
  end

  def create_filters(dynamic_values)
    filters = {}
    dynamic_values.each do |key, value|
      filters = extract_filter(filters, key, value)
      if filters.nil?
        render json: { error: "Bad Request: impossible to apply matchers filters: #{dynamic_values}" }, status: :bad_request
      end
    end
    filters
  end

  def extract_filter(filters, key, value)
    acceptable_filters = %w[gt gte lt lte eq in ne nin]
    index = key.to_s.rindex('.')
    return nil if index.nil?

    name = key.to_s[0..index - 1]
    operator = key.to_s[index + 1..-1]
    return nil unless acceptable_filters.include? operator

    if value.is_a?(Array)
      value.map! { |x| x.try(:float?) ? x.to_f : x }
    elsif value.try(:float?)
      value = value.to_f
    end
    filters[name] = if filters[name]
                      filters[name].merge('$' + operator => value)
                    else
                      { '$' + operator => value }
                    end
    filters
  end
end
