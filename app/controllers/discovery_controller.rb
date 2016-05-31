require 'rest-client'

class DiscoveryController < ApplicationController

  Catalog_Base_URL = 'someip/resource_catalog/query_resources?'

  def initialize
    SERVICES_CONFIG['resource_catalog'] = 'someip/resource_catalog/query_resources?'
    SERVICES_CONFIG['collector_service'] = 'someip/collector/'
  end

  def resources
    error_message = validate_url_params

    if error_message.blank?

      found_resources = call_to_resource_catalog(build_resource_catalog_url)

      found_resources.delete_if do |resource|
        resource_data = call_to_data_collector(resource)
        #returns true if capability data does not obey the restrictions and removes the resource from the list
        filter_resources(resource_data)

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

  end

  def build_resource_catalog_url

    query_string_url += SERVICES_CONFIG['resource_catalog'] + 'capability=' + params['capability']

    if params['radius'].blank? and not params['lat'].blank?
      query_string_url += ',' + 'lat=' + params['lat'] + ',' + 'lon=' + params['lon']
    elsif not params['radius'].blank? and not params['lat'].blank?
      query_string_url += ',' + 'lat=' + params['lat'] + ',' + 'lon=' + params['lon'] + ',' + params['radious']
    end

    return query_string_url
  end

  def build_collector_service_query (resource_id)

    query_string_url += SERVICES_CONFIG['collector_service'] + '/' + resource_id + '/' + params['capability'] + '?'

    if not params['start_range'].blank? and not params['end_range'].blank?
      query_string_url += 'start_range=' + params['start_range'] + ',' + 'end_range=' + params['end_range']
    end

    return query_string_url
  end

  def filter_resources(resource_data)

    delete_it = false

      #Clients wants exact value
      if (params['max_cap_data']==params['min_cap_data'])

        cap_data=params['max_cap_data']
        #value exists within the resource_data
        delete_it = !resource_data.include?(cap_data)

      #Client restriction has a range
      else
        if (not params['max_cap_data'].blank? and params['min_cap_data'].blank?)
          resource_data.each do |res_datum|
            delete_it = true if res_datum > params['max_cap_data']
          end
        elsif (params['max_cap_data'].blank? and not params['min_cap_data'].blank?)
          resource_data.each do |res_datum|
            delete_it = true if res_datum < params['min_cap_data']
          end
        elsif (not params['max_cap_data'].blank? and not params['min_cap_data'].blank?)
          resource_data.each do |res_datum|
            delete_it = true if res_datum < params['min_cap_data'] or res_datum > params['max_cap_data']
          end
        end
      end

    return delete_it
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

      if (params['radious'].blank? and not params['lon'].blank? and not params['lat'].blank?)
        error_message = +'Latitude and Longitude have not been specified \n'
      end

    else
      error_message = 'At least a capability must be defined to query for resources'
    end

    return error_message
  end

  private

  def call_to_resource_catalog(discovery_query)
	#uncoment this line when resource catalog is availible
	#JSON.parse (RestClient.get SERVICES_CONFIG["services_data_catalog"])

	  data_catalog_mockup(discovery_query)
  end

  def call_to_data_collector(resource)
	#uncoment this line when data collector is availible
	#JSON.parse (RestClient.get SERVICES_CONFIG["services_data_collector"])
    resource.data = data_collector_mockup(build_collector_service_query resource)
  end

  def data_collector_mockup(discovery_query)
    data = Hash.new

    uuids.each { |uuid|
        temp = Hash.new
        temp = {:lat => lat, :lon => lon}
        data[uuid] = temp
    }
    data
  end

  def data_catalog_mockup (discovery_query)
    hash_uuids = {:uuids => ["1111","2222"]}
    hash_uuids.to_json
  end

end
