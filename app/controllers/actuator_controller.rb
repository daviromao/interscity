require 'json'

class ActuatorController < ApplicationController

  # POST /commands
  def create
    @response = Hash.new
    @response['success'] = []
    @response['failure'] = []

    begin
      command_params = params[:data]

      command_params.each do |actuator|
        apply_command(actuator, params)
      end

      render json: @response, status: 200
    rescue StandardError => e
      render json: {error: e.message}, status: 400
      return false
    end
  end

  # GET /commands
  # GET /commands?status=pending&uuid=1234&capability=semaphore
  def index
    @commands = ActuatorCommand.filter(params.slice(:status, :uuid, :capability)).recent
    render json: {commands: @commands}, status: 200
  end

  private

  def add_failure(uuid, code, error, capability = nil, value = nil)
    @response['failure'] << {
      uuid: uuid,
      code: code,
      error: error,
      capability: capability,
      value: value
    }
  end

  def apply_command(actuator, params)
    resource = PlatformResource.where(uuid: actuator['uuid']).first

    actuator['capabilities'].each do |capability, value|
      if resource.blank?
        add_failure(actuator['uuid'], 404, "Resource not found", capability, value)
      elsif resource.capabilities.include? capability
        command = ActuatorCommand.new(
          platform_resource: resource,
          uuid: resource.uuid,
          capability: capability,
          value: value
        )

        if command.save
          @response['success'] << command
        else
          add_failure(resource.uuid, 400, "Invalid command #{command.errors.full_messages}", capability, value)
        end
      else
        add_failure(resource.uuid, 400,  "This resource does not have such cappability", capability, value)
      end
    end
  end
end
