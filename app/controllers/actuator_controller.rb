require 'rest-client'
require 'json'
require 'tools/validate_params'
require 'mocks/resource_adaptor_mock'

class ActuatorController < ApplicationController

  def initialize
    @SERVICES_CONFIG = Hash.new
    @SERVICES_CONFIG['resource_adaptor'] = 'someip/basic_resources/1/'
  end

  def exec
  
    status =''
    begin

      execParams = JSON.parse(request.body.string)
      if (ValidateParams.validate_cap_exec(execParams))
        #find resource url in local database with uuid
        

        res=Resource.find_by(uuid:execParams['uuid'])
        #execute capability in the specific
        status = ResourceAdaptorMock.execute_actuator_capability(execParams,res.uri)
      else
        status = 400
      end

    rescue Exception => e
      render error_payload(e.message,400)
    else
      render json: {status: status}, status: status
    end
  end

  def status

    error_message = validate_url_params

    if not error_message.blank?
      res=Resource.find_by(uuid:params['uuid'])
      response = ResourceAdaptorMock.actuator_status_mock(params, res.uri)

      if response!=400
        render json: response
      else
        render json: response , status: response
      end

    else
      render error_payload(error_message,400)
    end

  end

  def create
    status =''
    begin
      execParams = JSON.parse(request.body.string)

      if (ValidateParams.validate_resource_catalog_creation(execParams))
        #Create a new resource

        Resource.create(name:execParams['name'],uuid:execParams['uuid'],uri:execParams['uri'])
        #Sucessfull creation
        status = 201
      else
        status =400
      end
    rescue Exception => e
      render error_payload(e.message,400)
    else
      render json: {status: status}, status: status
    end
  end

  def update
    status =''
    begin
      updateParams = JSON.parse(request.body.string)
      if (ValidateParams.validate_resource_catalog_update(updateParams))

        #find resource url in local database with uuid
        res=Resource.find_by(uuid:updateParams['uuid'])
        res.uri = updateParams['uri']
        res.name = updateParams['name']
        res.save
        status = 200
      else
        status = 400
      end
    rescue Exception => e
      render error_payload(e.message,400)
    else
      render json: {status: status}, status: status
    end
  end


  private

  def validate_url_params

    error_message = ''

    if request.GET.size != 0

      if params['uuid'].blank?
        error_message = + 'UUID has to be Specified \n'
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
