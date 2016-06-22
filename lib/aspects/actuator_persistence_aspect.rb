require 'aspector'

class ActuatorPersistenceAspect < Struct.new(:permission_name)

  def after (controller)
    begin
      debugger
      if(controller.request_status==200)
        actuate_params = controller.params[:data]
        res = Resource.find_by(uuid: actuate_params['uuid'])
        cap = res.capabilities.find_by(name: actuate_params['capability']['name'])
        ActuatorValue.create(value: actuate_params['capability']['value'], capability_id: cap.id, resource_id: res.id)
        puts 'New actuator status successfully stored'
      end
    rescue Exception => e
      puts e.message
    end

  end

end