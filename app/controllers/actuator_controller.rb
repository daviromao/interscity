require 'rest-client'
require 'json'
require 'tools/validate_params'
require 'mocks/resource_adaptor_mock'
require 'aspects/actuator_persistence_aspect'
require 'aspects/json_validation_aspect'
require 'exceptions/actuator_exception'

class ActuatorController < ApplicationController

  before_action JsonValidationAspect,:only=>[:actuate]
  #before_action :json_validation, :only=>[:actuate]
  #after_action ActuatorPersistenceAspect.new(:only=>[:actuate])

  attr_accessor :request_status

  def initialize

  end

  def actuate
    debugger
    @request_status = 0
    begin
      actuate_params = params[:data]
      res=Resource.find_by(uuid: actuate_params['uuid'])

      if not res.blank?
        @request_status = ResourceAdaptorMock.execute_actuator_capability(actuate_params, res.uri)
      else
        raise ActuatorException.new(404)
      end
    rescue ActuatorException => e
      render error_payload(e.message, e.request_status)
    rescue Exception => e
      render error_payload(e.message, 500)
    else
      render json: {request_status: @request_status}, request_status: @request_status
    end
  end

  def value
    debugger
    error_message = validate_url_params
    if not error_message.blank?
      res=Resource.find_by(uuid: params['uuid'])
      response = ResourceAdaptorMock.actuator_status_mock(params, res.uri)
      if response!=400
        render json: response
      else
        render json: response, status: response
      end
    else
      render error_payload(error_message, 400)
    end
  end

  def create
    debugger
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
    debugger
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

  def respond_error (exception,code)
    render error_payload(exception, code)
  end

  def json_validation ()
    begin
      debugger
      params.require(:data).permit(:uuid,:capability => [:name,:value])
    rescue Exception => e
      respond_error e, 400
      return false
    end
  end

  def validate_url_params
    error_message = ''
    debugger
    if request.GET.size != 0
      if params['uuid'].blank?
        error_message = +'UUID has to be Specified \n'
      end
      if (not params['capability'].blank?)
        error_message = +'Capability has not been specified \n'
      end
    else
      error_message = 'The capability and UUID must be defined'
    end
    return error_message
  end
end