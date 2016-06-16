require 'rest-client'
require 'json'

class DiscoveryController < ApplicationController

  Catalog_Base_URL = 'someip/resource_catalog/query_resources?'

  def initialize
    @SERVICES_CONFIG = Hash.new
    @SERVICES_CONFIG['resource_catalog'] = 'someip/resource_catalog/query_resources?'
    @SERVICES_CONFIG['collector_service'] = 'someip/collector/'
  end

  def resources
    error_message = validate_url_params

    if error_message.blank?

      found_resources = JSON.parse(call_to_resource_catalog(build_resource_catalog_url))
      
      #if(not validate_collector_url and not found_resources.blank?)
      if(not found_resources.blank? and validate_collector_url)
        found_resources['uuids'].delete_if do |resource|
            resource_data = JSON.parse(call_to_data_collector(resource))
            #returns true if capability data does not obey the restrictions and removes the resource from the list
            filter_resources(resource_data['capability_values'])
        end
      end
    else
      render error_payload(error_message,400)
      return true
    end

    if not found_resources.empty?
      render json: found_resources.to_json
    else

      render error_payload('No resources have been found',404)
    end
  end

  def build_resource_catalog_url

    query_string_url = @SERVICES_CONFIG['resource_catalog'] + 'capability=' + params['capability']

    if params['radius'].blank? and not params['lat'].blank?
      query_string_url += ',' + 'lat=' + params['lat'] + ',' + 'lon=' + params['lon']
    elsif not params['radius'].blank? and not params['lat'].blank?
      query_string_url += ',' + 'lat=' + params['lat'] + ',' + 'lon=' + params['lon'] + ',' + 'radius=' + params['radius']
    end

    return query_string_url
  end

  def build_collector_service_query (resource_id)

    query_string_url = @SERVICES_CONFIG['collector_service'] + '/' + resource_id['uuid'] + '/' + params['capability'] + '?'

    if not params['start_range'].blank? and not params['end_range'].blank?
      query_string_url += 'start_range=' + params['start_range'] + ',' + 'end_range=' + params['end_range']
    end

    return query_string_url
  end

  def filter_resources(resource_data)

    delete_it = false

    params['max_cap_value'] = params['max_cap_value'].to_i
    params['min_cap_value'] = params['min_cap_value'].to_i

    resource_data.each { |res_datum|
      res_datum['cap_value']=res_datum['cap_value'].to_i
    }

    if (not params['max_cap_value'].blank? or not params['min_cap_value'].blank?)
      #Clients wants exact value
      if (params['max_cap_value']==params['min_cap_value'])
        delete_it = !resource_data.include?(params['max_cap_value'])
      #Client restriction has a range
      else
        if (not params['max_cap_value'].blank? and params['min_cap_value'].blank?)
          resource_data.each do |res_datum|
            if(res_datum['cap_value'] > params['max_cap_value'])
              delete_it = true
              return delete_it
            end
          end
        elsif (params['max_cap_value'].blank? and not params['min_cap_value'].blank?)
          resource_data.each do |res_datum|
            if(res_datum['cap_value'] < params['min_cap_value'])
              delete_it = true
              return delete_it
            end
          end
        elsif (not params['max_cap_value'].blank? and not params['min_cap_value'].blank?)
          resource_data.each do |res_datum|
            if ( res_datum['cap_value'] > params['max_cap_value'] or res_datum['cap_value']< params['min_cap_value'])
              delete_it = true
              return delete_it
            end
          end
        end
      end
    elsif (not params['cap_value'].blank?)
      delete_it = !resource_data.include?(params['cap_value'])
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
    #uncoment this line when resource catalog is availible
    #JSON.parse (RestClient.get SERVICES_CONFIG["services_data_catalog"])

    data_catalog_mockup(discovery_query)
  end

  def call_to_data_collector(resource)
    #uncoment this line when data collector is availible
    #JSON.parse (RestClient.get SERVICES_CONFIG["services_data_collector"])
    data_collector_mockup(build_collector_service_query(resource),resource)
  end

  def data_collector_mockup(colector_query,resource)
    data = Hash.new
    if params['start_date'].blank? and params['end_date'].blank?

      case resource['uuid']
        when '4'
          data = {uuid:'4',capability_values: [{cap_value: 19,time_stamp:'2016-01-01T23:30:21'}]}
        when '5'
          data = {uuid:'5',capability_values: [{cap_value: 31,time_stamp:'2016-01-01T23:30:21'}]}
        when '7'
          data = {uuid:'7',capability_values: [{cap_value: 25,time_stamp:'2016-01-01T23:30:21'}]}
      end

    else
      data = {:uuids => resource, :value => ["1111"]}
    end
    data.to_json
  end

  def data_catalog_mockup (discovery_query)

    if (params['radius'].blank? and not params['lat'].blank? and not params['lon'].blank?)
      hash_uuids = {uuids: [{uuid:'2', lat: '20', lon: '20'},{uuid:'3', lat: '30', lon: '30'}]}
    elsif params['radius'].blank?
      hash_uuids =  {uuids: [{uuid:'1', lat: '10', lon: '10'},{uuid:'2', lat: '20', lon: '20'},{uuid:'3', lat: '30', lon: '30'}]}
    else
      hash_uuids = {uuids: [{uuid:'4', lat: '40', lon: '40'},{uuid:'5', lat: '40', lon: '40'},{uuid:'7', lat: '40', lon: '40'}]}
    end

    if (params['radius']=="80")
      hash_uuids = {}
    end
    #The data catalog will return json formatted data
    hash_uuids.to_json
  end

end
