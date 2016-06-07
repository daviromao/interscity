require 'rest-client'
require 'json'

class ActuatorController < ApplicationController

  def exec
    render json: {data: params['capability']}
  end

  def status
    render json: {data: params['capability']}
  end

  def create

  end

  def update

  end

end