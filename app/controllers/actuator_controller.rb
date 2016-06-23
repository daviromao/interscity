require 'rest-client'
require 'json'
require 'tools/validate_params'
require 'mocks/resource_adaptor_mock'
require 'exceptions/actuator_exception'

class ActuatorController < ApplicationController

  before_action :actuate_json_validation, :only=>[:actuate]
  before_action :validate_url_params, :only=>[:cap_status]
  after_action :actuator_capability_persistence,:only => [:actuate]

  def initialize

  end

  def actuate
    response = String.new
    begin
      actuate_params = params[:data]
      res=Resource.find_by(uuid: actuate_params['uuid'])

      if !res.blank?
        response = call_to_actuator_actuate res.uri
        render response
      else
        raise ActuatorException.new(404)
      end
    rescue Exception => e
      render error_payload(e.message, e.request_status)
    end
  end

  def cap_status
    response = String.new
    begin
      res=Resource.find_by(uuid: params['uuid'])

      if !res.blank?
        response=call_to_actuator_cap_status res.uri
        if response.code==200
          render json: Json.parse(response), status: response.code
        else
          raise ActuatorException.new(response.code)
        end
      else
        raise ActuatorException.new(404)
      end
    rescue Exception => e
      render error_payload(e.message, e.request_status)
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

  def respond_error (exception, code)
    render error_payload(exception.messsage, code)
  end

  #TODO complete resource adaptor url
  def call_to_actuator_cap_status(actuator_url)
    request_url = actuator_url + '/componentes/'
    RestClient.get(request_url)
  end

  #TODO complete resource adaptor url
  def call_to_actuator_actuate(actuator_url)
    request_url = actuator_url + '/componentes/'
    RestClient.put(request_url)
  end

  def actuate_json_validation
    begin
      params.require(:data).permit(:uuid, :capability => [:name, :value])
    rescue Exception => e
      respond_error e, 400
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
    if !request.GET.empty?
      if params['uuid'].blank?
        error_message = +'UUID has to be Specified \n'
      end
      if params['capability'].blank?
        error_message = +'Capability has not been specified \n'
      end
    else
      error_message = 'The capability and UUID must be defined'
    end
    if !error_message.blank?
      respond_error error_message, 404
    end

  end
end