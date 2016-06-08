require 'rest-client'
require 'json'

class ActuatorController < ApplicationController

def initialize
    SERVICES_CONFIG['resource_adaptor'] = 'someip/basic_resources/1/'
  end

  def exec
    render json: {data: params['capability']}
  end

  def status
    #qual recurso
    resource = Resource.find_by(uuid: params[:uuid])

    #qual capacidade
    capability = params[:capability]

    #pegar resposta do o adaptor
    response = make_request resource.id.to_s

    #rederizar a resposta de volta para o cliente
    render json: {status: response[:last_collection][capability]}
  end

  def create

  end

  def update

  end

  def make_request(resource_id)
    GET SERVICES_CONFIG['resource_adaptor'] + "components/" + resource_id
  end
end
