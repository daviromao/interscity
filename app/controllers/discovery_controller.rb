require 'rest-client'
require 'json'

class DiscoveryController < ApplicationController
  def initialize
    @CATALOG_URL = SERVICES_CONFIG['services']['catalog'] +  '/resources/search?'
    @COLLECTOR_URL = SERVICES_CONFIG['services']['collector'] + '/resources/data/last'
  end

  def resources
    error_message = validate_url_params
    begin
      if error_message.blank?
        found_resources = call_to_resource_catalog(build_resource_catalog_url)

        if(not found_resources.blank? and validate_collector_url)
          uuids = []
          found_resources['resources'].each do |resource|
            uuids << resource['uuid']
          end

          collector_response = call_to_data_collector(uuids)

          collector_uuids = []
          collector_response['resources'].each do |resource|
            collector_uuids << resource['uuid']
          end

          found_resources['resources'].select! do |resource|
            collector_uuids.include?(resource['uuid'])
          end
        end
      else
        render error_payload(error_message,400)
        return true
      end

      if not found_resources.empty?
        render json: found_resources
      else
        render error_payload('No resources have been found',404)
      end
    rescue
      render error_payload('Service Unavailable', 503)
    end
  end

  def build_resource_catalog_url
    query_string_url = @CATALOG_URL + 'capability=' + params['capability']

    if params['radius'].blank? and not params['lat'].blank?
      query_string_url += '&' + 'lat=' + params['lat'] + '&' + 'lon=' + params['lon']
    elsif not params['radius'].blank? and not params['lat'].blank?
      query_string_url += '&' + 'lat=' + params['lat'] + '&' + 'lon=' + params['lon'] + '&' + 'radius=' + params['radius']
    end

    return query_string_url
  end

  def validate_url_params
    error_message = ''

    if request.GET.size != 0

      if params['capability'].blank?
        error_message = + 'Capability has to be Specified \n'
      end

      if (not params['lat'].blank? and params['lon'].blank?)
        error_message = +'Longitude has not been specified \n'
      end

      if (params['lat'].blank? and not params['lon'].blank?)
        error_message = +'Latitude has not been specified \n'
      end

      if (not params['radius'].blank? and params['lon'].blank? and params['lat'].blank?)
        error_message = +'To use radius Latitude and Longitude must be specified \n'
      end

    else
      error_message = 'At least a capability must be defined to query for resources'
    end

    return error_message
  end

  private

  def validate_collector_url()
    if (url_param_checker(['min_cap_value']) or url_param_checker(['max_cap_value']) or url_param_checker(['cap_value']))
      return true
    end
  end

  def url_param_checker (args)
    valid_url=true
    args.each { |arg|
      if (params[arg].blank?)
        valid_url = false
      end
    }
    valid_url
  end


  def call_to_resource_catalog(discovery_query)
    response = JSON.parse(RestClient.get(discovery_query))
  end

  def call_to_data_collector(uuids)
    filters = {
      data: {
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
    response = JSON.parse(RestClient.post(COLLECTOR_URL, filters, content_type: 'application/json'))
  end

end
