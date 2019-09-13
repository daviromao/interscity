# frozen_string_literal: true

require 'rest-client'
require 'json'

# Controller that process clients requests
class DiscoveryController < ApplicationController
  prepend_before_action :set_parameter_variables
  before_action :validate_url_params
  before_action :find_resources_on_catalog

  attr_accessor :catalog_url

  def initialize
    @catalog_url = SERVICES_CONFIG['services']['catalog'] + '/resources/search?'
    @collector_url = SERVICES_CONFIG['services']['collector'] + '/resources/search'
  end

  def resources
    if @found_resources.present?
      uuids = ids_from_catalog
      if @informed_matchers_params.present?
        collector_uuids = data_from_collector(uuids)
        return nil unless collector_uuids

        matched_resources(collector_uuids)
      end
    end
    if @found_resources.present?
      render json: @found_resources
    else
      render error_payload('No resources have been found', 404)
    end
  end

  private

  def matched_resources(collector_uuids)
    @found_resources['resources'].select! do |resource|
      collector_uuids.include?(resource['uuid'])
    end
  end

  def data_from_collector(uuids)
    collector_response = call_to_data_collector(uuids)
    collector_response['resources']
  rescue StandardError
    render error_payload('The data collector service is unavailable', 503)
    nil
  end

  # This method is not being covered by the rspec because it dependents on the real service and it response is not predictable
  def find_resources_on_catalog
    @found_resources = call_to_resource_catalog(build_resource_catalog_url)
  rescue Exception => e
    render error_payload('The resource catalog service is unavailable', 503)
  end

  def ids_from_catalog
    @found_resources['resources'].map do |resource|
      resource['uuid']
    end
  end

  def build_resource_catalog_url
    query_string_url = @catalog_url
    informed_location_params = @informed_search_params & @location_params
    capability_param = @informed_params & @capability_params
    catalog_params = informed_location_params + capability_param
    catalog_params.each do |name|
      query_string_url += "#{name}=#{params[name]}&"
    end

    query_string_url
  end

  def validate_url_params
    error_message = []

    if !request.GET.empty?
      error_message += verify_nil_params
      error_message += verify_matchers_params
      error_message += verify_location_params
    else
      error_message << 'At least one filter parameter must be defined to query for resources'
    end

    render error_payload(error_message, 400) if error_message.present?
  end

  def verify_nil_params
    error_message = []
    @informed_search_params.each do |name|
      error_message << "The parameter #{name} can't be blank or empty" if params[name].blank?
    end
    error_message
  end

  def verify_matchers_params
    error_message = []
    @informed_matchers_params.each do |key, _value|
      index = key.to_s.rindex('.')
      if index.nil?
        error_message << "The parameter #{key} is missing an operator"
        next
      end
      name = key.to_s[0..index - 1]
      operator = key.to_s[index + 1..-1]
      unless @available_matchers.include?(operator)
        error_message << "The operator '#{operator}' in the parameter '#{key}' is not supported"
      end
    end
    error_message
  end

  def verify_location_params
    error_message = []
    if params['lat'].present? && params['lon'].blank?
      error_message << 'Longitude (lon) has not been specified'
    elsif params['lat'].blank? && params['lon'].present?
      error_message << 'Latitude (lat) has not been specified'
    elsif params['radius'].present? && params['lon'].blank? && params['lat'].blank?
      error_message << "You must provide the location (lat and lon) to use the 'radius' parameter"
    end
    error_message
  end

  def set_parameter_variables
    @location_params = %w[lat lon radius]
    @capability_params = ['capability']
    @basic_params = @location_params + @capability_params + %w[controller action]
    @available_matchers = %w[eq gt gte lt lte ne in nin]

    @informed_params = params.keys
    @informed_search_params = @informed_params - %w[controller action]
    @informed_matchers_params = @informed_search_params - @basic_params
  end

  def call_to_resource_catalog(discovery_query)
    JSON.parse(RestClient.get(discovery_query))
  end

  # This method is not being covered by the rspec because it dependents on the real service and it response is not predictable
  def call_to_data_collector(uuids)
    filters = { matchers: {}, uuids: uuids }
    @informed_matchers_params.each do |matcher|
      filters[:matchers][matcher] = params[matcher]
    end
    JSON.parse(RestClient.post(@collector_url, filters, content_type: 'application/json'))
  end
end
