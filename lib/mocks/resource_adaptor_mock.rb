class ResourceAdaptorMock

  def self.traffic_light_exec_mock (json, url)
    if(json['capability']['value']=='red')
      return 201
    end
    if(json['capability']['value']=='green')
      return 201
    end
    if(json['capability']['value']=='blue')
      return 400
    end
  end

  def self.actuator_status_mock (params, url)
    if(params['capability']=='trafficlight')
      return 'green'
    end
    if(params['capability']=='temperature')
      return 400
    end
  end



end