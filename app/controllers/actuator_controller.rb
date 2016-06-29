require 'rest-client'
require 'json'

class ActuatorController < ApplicationController

  before_action :actuate_json_validation, :only => [:actuate]
  before_action :validate_url_params, :only => [:cap_status]
  after_action :actuator_capability_persistence, :only => [:actuate]

  def actuate
    @response = Hash.new
    @response['success'] = []
    @response['failure'] = []
    begin
      actuate_params = params[:data]
      execute_actuation(actuate_params, @response)
      render json: @response
    rescue Exception => e
      render error_payload(e.message, 500)
    end
  end

  def cap_status
    begin
      value_register = ActuatorValue.where(capability_id: @capability.id,
                                           platform_resource_id: @resource.id).order('created_at DESC').first

      response = {}
      if value_register.blank?
        response = call_to_actuator_cap_status
      else
        response[:data] = value_register.value
        response[:updated_at] = value_register.created_at
      end
      render json: response
    rescue RestClient::ExceptionWithResponse => e
      render error_payload(e.response.message, e.response.code)
    rescue Exception => e
      render error_payload(e.message, 500)
    end
  end


  private

  def execute_actuation(actuate_params, response)
    actuate_params.each { |actuator|
      uuid = actuator['uuid']
      capabilities = actuator['capabilities']
      capability = capabilities.first.first
      value = capabilities.first.second
      begin
        res = PlatformResource.find_by(uuid: uuid)
        if !res.blank?

          actuator_response = JSON.parse(call_to_actuator_actuate(res.uri, capability, value))

          resource = actuator_response['data']
          resource['code'] = actuator_response['code']
          resource['capability'] = capability
          resource['uuid'] = uuid
          response['success'] << resource
        else
          response['failure'] << {uuid: actuator['uuid'], capability: capability, code: 404, message: "Resource not found"}
        end
      rescue RestClient::ExceptionWithResponse => e
        response['failure'] << {uuid: actuator['uuid'], capability: capability, code: e.response.code, message: e.response.message}
      rescue Exception => e
        response['failure'] << {uuid: actuator['uuid'], capability: capability, code: 500, message: e.message}
      end
    }
  end

  #TODO complete resource adaptor url
  def call_to_actuator_cap_status
    request_url = @resource.uri + '/collect/' + @capability.name
    JSON.parse(RestClient.get(request_url))
  end

  #TODO complete resource adaptor url
  def call_to_actuator_actuate(actuator_url, capability, value)
    request_url = actuator_url + '/actuate/'+ capability.to_s
    response = RestClient.put(request_url, {data: {value: value}})
    json_response = JSON.parse(response.body)
    json_response[:code] = response.code
    json_response.to_json
  end

  def actuate_json_validation
    begin
      params.require(:data).each { |actuator|
        actuator.permit(:uuid, :capabilities => {}) }
    rescue Exception => e
      render error_payload(e.message, 400)
      return false
    end
  end

  def actuator_capability_persistence
    begin
      @response['success'].each do |actuator_success|
        cap = Capability.find_by(name: actuator_success['capability'])
        res = PlatformResource.find_by(uuid: actuator_success['uuid'])
        ActuatorValue.create(capability_id: cap.id, platform_resource_id: res.id, value: actuator_success['state'])
      end
    rescue Exception => e
    end
  end

  def validate_url_params
    if (!params['uuid'].blank? and !params['capability'].blank?)
      @resource = PlatformResource.find_by(uuid: params['uuid'])
      if (@resource)
        @capability = @resource.capabilities.find_by(name: params['capability'])
        if (!@capability)
          render error_payload('Capability not found', 404)
        end
      else
        render error_payload('Actuator not found', 404)
      end
    end
  end
end
