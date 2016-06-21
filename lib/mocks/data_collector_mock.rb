class DataCollectorMock
  
  def self.call(resource, params, services_config)
    #uncoment this line when data collector is availible
    #JSON.parse (RestClient.get SERVICES_CONFIG["services_data_collector"])
    
    data_collector_query = DataCollectorMock.build_data_collector_query(resource, params, services_config)
    
    DataCollectorMock.call_service(data_collector_query ,resource, params)
  end

  
  private

  def self.call_service(colector_query,resource, params)
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
  
  def self.build_data_collector_query (resource_id, params, services_config)

    query_string_url = services_config['collector_service'] + '/' + resource_id['uuid'] + '/' + params['capability'] + '?'

    if not params['start_range'].blank? and not params['end_range'].blank?
      query_string_url += 'start_range=' + params['start_range'] + ',' + 'end_range=' + params['end_range']
    end

    return query_string_url
  end
  
end