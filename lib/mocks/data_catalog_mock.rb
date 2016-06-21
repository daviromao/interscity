class DataCatalogMock
   def self.call(discovery_query, params)

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