require 'rest-client'
require 'json'
require 'tools/validate_params'
require 'mocks/resource_adaptor_mock'
require 'exceptions/actuator_exception'

class ActuatorController < ApplicationController

  before_action :actuate_json_validation, :only=>[:actuate]
  before_action :validate_url_params, :only=>[:cap_status]
  after_action :actuator_capability_persistence,:only => [:actuate]

  def actuate
    response = Hash.new
    response['success'] = []
    response['failure'] = []
    begin
      actuate_params = params[:data]
      execute_actuation(actuate_params, response)
    rescue Exception => e
      render error_payload(e.message, 500)
    else
      render json: response
    end
  end

  def cap_status
    response = String.new
    begin
      res = Resource.find_by(uuid: params['uuid'])
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

  def create
    status =''
    begin
      execParams = params[:data]
      if (ValidateParams.validate_resource_catalog_creation(execParams))
        #Create a new resource
        Resource.create(name: execParams['name'], uuid: execParams['uuid'], uri: execParams['uri'])
        #Sucessfull creation
        status = 201
      else
        status =400
      end
    rescue Exception => e
      render error_payload(e.message, 400)
    else
      render json: {request_status: status}, request_status: status
    end
  end

  def update
    status =''
    begin
      updateParams = params[:data]
      if (ValidateParams.validate_resource_catalog_update(updateParams))
        #find resource url in local database with uuid
        res=Resource.find_by(uuid: updateParams['uuid'])
        res.uri = updateParams['uri']
        res.name = updateParams['name']
        res.save
        status = 200
      else
        status = 400
      end
    rescue Exception => e
      render error_payload(e.message, 400)
    else
      render json: {request_status: status}, request_status: status
    end
  end


  private

  def execute_actuation(actuate_params, response)
    actuate_params.each { |actuator|
      begin
        res=Resource.find_by(uuid: actuator['uuid'])
        if !res.blank?
          actuator_response = JSON.parse(call_to_actuator_actuate res.uri)

          if (actuator_response['code'] == 200)
            actuator_response['uuid'] = actuator['uuid']
            response['success'] << actuator_response
          else
            actuator_response['uuid'] = actuator['uuid']
            response['failure'] << actuator_response
          end
        else
          raise ActuatorException.new(404)
        end
      rescue ActuatorException => e
        response['failure'] << {uuid:actuator['uuid'],error_code:e.request_status}
      rescue Exception => e
        response['failure'] << {uuid:actuator['uuid'],error_code:500}
      end
    }
  end

  #TODO complete resource adaptor url
  def call_to_actuator_cap_status(actuator_url)
    request_url = actuator_url + '/componentes/' + params[:capability]
    RestClient.get(request_url)
  end

  #TODO complete resource adaptor url
  def call_to_actuator_actuate(actuator_url)
    request_url = actuator_url + '/actuate/'+params[:capability]
    response = RestClient.put(request_url,{value:''})
    json_response = JSON.parse(response.body)
    json_response[:code] = response.code
    json_response.to_json
  end

  def actuate_json_validation
    begin
      params.require(:data).each { |actuator|
        actuator.permit(:uuid, :capability => {})}
    rescue Exception => e
      render error_payload(e.message, 400)
      return false
    end
  end

  def actuator_capability_persistence
    begin
      if request_status==200
        actuate_params = controller.params[:data]
        res = Resource.find_by(uuid: actuate_params['uuid'])
        cap = res.capabilities.find_by(name: actuate_params['capability']['name'])
        ActuatorValue.create(value: actuate_params['capability']['value'], capability_id: cap.id, resource_id: res.id)
      end
    rescue Exception => e
      puts e.message
    end
  end

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