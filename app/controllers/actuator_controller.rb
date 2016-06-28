require 'rest-client'
require 'json'
require 'tools/validate_params'
require 'mocks/resource_adaptor_mock'
require 'exceptions/actuator_exception'

class ActuatorController < ApplicationController

  before_action :actuate_json_validation, :only=>[:actuate]
  before_action :validate_url_params, :only=>[:cap_status]
 # after_action :actuator_capability_persistence,:only => [:actuate]

  def actuate
    response = Hash.new
    response['success'] = []
    response['failure'] = []
    begin
      actuate_params = params[:data]
      execute_actuation(actuate_params, response)
      render json: response
    rescue Exception => e
      render error_payload(e.message, 500)
    end
  end

  def cap_status
    response = String.new
    begin
      res = PlatformResource.find_by(uuid: params['uuid'])
      cap = res.capabilities.find_by(name:params['capability'])

      if !res.blank? and !cap.blank?
        response=call_to_actuator_cap_status res.uri
        if response[:code]==200
          render json: response
        else
          raise ActuatorException.new(response.code)
        end
      else
        raise ActuatorException.new(404)
      end
    rescue ActuatorException => e
      render error_payload('Actuator not found', e.request_status)
    rescue Exception => e
      render error_payload(e.message, 500)
    end
  end


  private

  def execute_actuation(actuate_params, response)
    actuate_params.each { |actuator|
      begin
        uuid = actuator['uuid']
        capabilities = actuator['capabilities']
        res = PlatformResource.find_by(uuid: uuid)
        if !res.blank?
          capability = capabilities.first.first
          value = capabilities.first.second

          actuator_response = JSON.parse(call_to_actuator_actuate(res.uri, capability, value))

          resource = actuator_response['data']
          resource['code'] = actuator_response['code']
          resource['capability'] = capability
          resource['uuid'] = uuid
          response['success'] << resource
        else
          response['failure'] << {uuid:actuator['uuid'], code: 404, message: "Resource not found"}
        end
      rescue RestClient::ExceptionWithResponse=>e
        response['failure'] << {uuid: actuator['uuid'], capability: capability, code: e.response.code, message: e.response.message }
      rescue Exception => e
        response['failure'] << {uuid: actuator['uuid'], capability: capability, code: 500, message: e.message }
      end
    }
  end

  #TODO complete resource adaptor url
  def call_to_actuator_cap_status(actuator_url)
    request_url = actuator_url + '/actuate/' + params[:capability]
    RestClient.get(request_url)
  end

  #TODO complete resource adaptor url
  def call_to_actuator_actuate(actuator_url, capability, value)
    request_url = actuator_url + '/actuate/'+ capability.to_s
    response = RestClient.put(request_url,{data: {value: value}})
    json_response = JSON.parse(response.body)
    json_response[:code] = response.code
    json_response.to_json
  end

  def actuate_json_validation
    begin
      params.require(:data).each { |actuator|
        actuator.permit(:uuid, :capabilities => {})}
    rescue Exception => e
      render error_payload(e.message, 400)
      return false
    end
  end

 # def actuator_capability_persistence
 #   begin
 #     if request_status==200
 #       actuate_params = controller.params[:data]
 #       res = PlatformResource.find_by(uuid: actuate_params['uuid'])
 #       cap = res.capabilities.find_by(name: actuate_params['capability']['name'])
 #       ActuatorValue.create(value: actuate_params['capability']['value'], capability_id: cap.id, resource_id: res.id)
 #     end
 #   rescue Exception => e
 #     puts e.message
 #   end
 # end

  def validate_url_params
    error_message = ''

    if params['uuid'].blank?
      error_message = +'UUID has to be Specified \n'
    end
    if params['capability'].blank?
      error_message = +'Capability has not been specified \n'
    end

    if !error_message.blank?
      render error_payload(error_message, 400)
    end

  end
end
