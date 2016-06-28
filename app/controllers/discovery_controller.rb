require 'rest-client'
require 'json'

# Controller that process clients requests
class DiscoveryController < ApplicationController
  before_action :validate_url_params
  before_action :find_resources

  def initialize
    @catalog_url = SERVICES_CONFIG['services']['catalog'] + '/resources/search?'
    @collector_url = SERVICES_CONFIG['services']['collector'] + '/resources/data/last'
  end

  def resources
    if !@found_resources.blank? && validate_collector_url
      uuids = ids_from_catalog
      collector_uuids = data_from_collector(uuids)
      matched_resources(collector_uuids)
    end
    if !@found_resources.blank?
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
    begin
      collector_response = call_to_data_collector(uuids)
    rescue
      render error_payload('Service Unavailable', 503)
    end
    collector_response['resources'].map do |resource|
      resource['uuid']
    end
  end

  def find_resources
    begin
      @found_resources = call_to_resource_catalog(build_resource_catalog_url)
    rescue
      render error_payload('Service Unavailable', 503)
    end
  end

  def ids_from_catalog
    @found_resources['resources'].map do |resource|
      resource['uuid']
    end
  end

  def build_resource_catalog_url
    query_string_url = @catalog_url + 'capability=' + params['capability']

    if params['radius'].blank? && !params['lat'].blank?
      query_string_url += '&' + 'lat=' + params['lat'] + '&'
      query_string_url += 'lon=' + params['lon']
    elsif !params['radius'].blank? && !params['lat'].blank?
      query_string_url += '&' + 'lat=' + params['lat'] + '&'
      query_string_url += 'lon=' + params['lon'] + '&'
      query_string_url + 'radius=' + params['radius']
    end
  end

  def validate_url_params
    error_message = ''

    if !request.GET.empty?

      if params['capability'].blank?
        error_message = + 'Capability has to be Specified \n'
      end

      if !params['lat'].blank? && params['lon'].blank?
        error_message = +'Longitude has not been specified \n'
      end

      if params['lat'].blank? && !params['lon'].blank?
        error_message = +'Latitude has not been specified \n'
      end

      if !params['radius'].blank? && params['lon'].blank? && params['lat'].blank?
        error_message += 'To use radius Latitude and'
        error_message += 'Longitude must be specified \n'
      end

    else
      error_message = 'At least a capability must be defined to query for resources'
    end

    render error_payload(error_message, 400) unless error_message.blank?
  end

  def validate_collector_url
    if url_param_checker(['min_cap_value']) || url_param_checker(['max_cap_value']) || url_param_checker(['cap_value'])
      return true
    end
  end

  def url_param_checker(args)
    valid_url = true
    args.each do |arg|
      if params[arg].blank?
        valid_url = false
        break
      end
    end
    valid_url
  end

  def call_to_resource_catalog(discovery_query)
    JSON.parse(RestClient.get(discovery_query))
  end

  def call_to_data_collector(uuids)
    filters = {
      sensor_value: {
        uuids: uuids,
        capabilities: [params['capability']],
        range: {
          params['capability'] => {
            max: params['max_cap_value'],
            min: params['min_cap_value'],
            equal: params['cap_value']
          }
        }
      }
    }
    JSON.parse(RestClient.post(@collector_url, filters, content_type: 'application/json'))
  end
end
