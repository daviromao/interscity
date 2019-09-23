# frozen_string_literal: true

class CapabilitiesController < ApplicationController
  # GET /capabilities
  def index
    type = params[:capability_type]
    capabilities = if type.nil?
                     Capability.all
                   else
                     Capability.all_of_function type.to_sym
                   end

    render json: { capabilities: capabilities }, status: :ok
  end

  # GET /capabilities/:name
  def show
    capability = Capability.find_by(name: params[:name])
    if capability.nil?
      render json: { error: 'Capability not found' }, status: :not_found
    else
      render json: capability, status: :ok
    end
  rescue StandardError => e
    render json: { error: e }, status: :internal_server_error
  end

  # POST /capabilities
  def create
    begin
      capability = Capability.create_with_function(capability_type, create_params)
      raise StandardError, capability.errors.full_messages.first unless capability.valid?

      result = capability.to_json(except: :function, methods: :capability_type)

      status = 201
    rescue StandardError => e
      result =  { error: e }
      status =  400
    end

    render json: result, status: status
  end

  # PATCH /capabilities/:name
  # PUT /capabilities/:name
  def update
    begin
      capability = Capability.find_by name: params[:name]
      raise ActiveRecord::RecordNotFound, 'capability not found' if capability.nil?

      capability.update!(update_params)
      result = Capability.first.to_json(except: :function, methods: :capability_type)
      status = 202
    rescue ActiveRecord::RecordNotFound => e
      result = { error: e }
      status = 404
    end
    render json: result, status: status
  end

  # DELETE /capabilities/:name
  def destroy
    capability = Capability.find_by name: params[:name]
    raise ActiveRecord::RecordNotFound, 'capability not found' if capability.nil?

    capability.delete
    render status: :no_content
  rescue StandardError
    render json: { error: 'no capability found' }, status: :not_found
  end

  private

  def create_params
    params.permit(:name, :description)
  end

  def update_params
    params.permit(:name, :description)
  end

  def capability_type
    capability_type = params[:capability_type].try(:to_sym)

    raise StandardError, 'Bad capability_type' if capability_type.nil? || !Capability.valid_function?(capability_type)

    capability_type
  end
end
