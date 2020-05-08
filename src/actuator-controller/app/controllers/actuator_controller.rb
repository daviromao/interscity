# frozen_string_literal: true

require 'json'

class ActuatorController < ApplicationController
  before_action :set_page_params, only: [:index]

  # POST /commands
  def create
    @response = {}
    @response['success'] = []
    @response['failure'] = []

    begin
      command_params = params[:data]

      command_params.each do |actuator|
        apply_command(actuator, params)
      end

      render json: @response, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_request
      return false
    end
  end

  # GET /commands
  # GET /commands?status=pending&uuid=1234&capability=semaphore
  def index
    @commands = ActuatorCommand
                .filter(params.slice(:status, :uuid, :capability))
                .recent.page(@page).per(@per_page)

    render json: { commands: @commands }, status: :ok
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

  def create_command(resource, capability, value)
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
  end

  def apply_command(actuator, _params)
    resource = PlatformResource.where(uuid: actuator['uuid']).first

    actuator['capabilities'].each do |capability, value|
      if resource.blank?
        add_failure(actuator['uuid'], 404, 'Resource not found', capability, value)
      elsif resource.capabilities.include? capability
        create_command(resource, capability, value)
      else
        add_failure(resource.uuid, 400, 'This resource does not have such capability', capability, value)
      end
    end
  end

  def set_page_params
    @page = params[:page].blank? ? 1 : params[:page].to_i
    @per_page = params[:per_page].blank? ? 40 : params[:per_page].to_i
  end
end
