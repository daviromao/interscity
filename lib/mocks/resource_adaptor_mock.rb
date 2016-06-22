require 'exceptions/actuator_exception'

class ResourceAdaptorMock

  def self.execute_actuator_capability (json,uri)
    
    case uri
      when 'traffic_light_url'
        traffic_light_exec_mock json, uri
      else
        puts 'The actuator does not respond trough this URL'
        raise ActuatorException.new(404)
    end
  end

  def self.actuator_status_mock (params, uri)
    if(params['capability']=='trafficlight')
      return 'green'
    end
    if(params['capability']=='temperature')
      raise ActuatorException.new(400)
    end
  end

  private

  def self.traffic_light_exec_mock (json, uri)

    if(json['capability']['value']=='red')
      return 200
    end
    if(json['capability']['value']=='green')
      return 200
    end
    if(json['capability']['value']=='blue')
      raise ActuatorException.new(400)
    end
  end

end