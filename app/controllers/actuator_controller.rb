require 'json'

class ActuatorController < ApplicationController
  def actuate
    @response = Hash.new
    @response['success'] = []
    @response['failure'] = []

    begin
      command_params = params[:data]

      command_params.each do |actuator|
        resource = PlatformResource.where(uuid: actuator['uuid']).first
        unless resource
          @response['failure'] << {
            uuid: actuator['uuid'],
            code: 404,
            error: "Resource not found",
            capability: actuator['capability'],
            value: actuator['value']
          }
          next
        end

        actuator['capabilities'].each do |capability, value|
          if resource.capabilities.include? capability
            command = ActuatorCommand.new(
              platform_resource: resource,
              uuid: resource.uuid,
              capability: capability,
              value: value
            )

            if command.save
              @response['success'] << command
            else
              @response['failure'] << {uuid: resource.uuid, capability: capability, value: value, code: 400, error: "Invalid command #{command.errors.full_messages}"}
            end
          else
            @response['failure'] << {uuid: resource.uuid, capability: capability, value: value, code: 400, error: "This resource does not have such cappability"}
          end
        end
      end
      render json: @response, status: 200
    rescue StandardError => e
      render json: {error: e.message}, status: 400
      return false
    end
  end
end
