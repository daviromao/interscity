require 'notification'

class BasicResourcesController < ApplicationController
  include SmartCities::Notification

  # POST /resources
  # Errors
  # => 422 unprocessable entity
  def create
    resource = BasicResource.new(component_params)
    begin
      resource.save!
      if capability_params[:capabilities].present?
        capability_params[:capabilities].each do |cap|
          query = Capability.where(name: cap)
          raise if query.empty?
          resource.capabilities << query.take
        end
      end
      render json: {data: resource.to_json}, status: 201, location: basic_resource_url(resource)
    rescue
      render json: {
        error: "Error while creating basic resource"
      }, status: 422
    end
  end

  # GET /resources/sensors
  def index_sensors
    render json: BasicResource.all_sensors
  end

  # GET /resources/actuators
  def index_actuators
    render json: BasicResource.all_actuators
  end

  # GET /resources/:uuid
  def show
    begin
      render json: { data: BasicResource.find_by_uuid!(params[:uuid]).to_json }
    rescue
      render json: {
        error: "Resource with given uuid not found"
      }, status: 404
    end
  end

  # PUT /resources/:uuid
  def update
    resource = BasicResource.find_by_uuid(params[:uuid])
    begin
      resource.update!(component_params)
      if capability_params[:capabilities].present?
        capability_params[:capabilities].each do |cap|
          query = Capability.where(name: cap)
          raise if query.empty?
          resource.capabilities << query.take
        end
      end
      notify_resource_update(resource)
    rescue
      render json: {
        error: "Error while updating basic resource"
      }, status: 422
    end
  end

  private

    def component_params
      params.require(:data).permit(:description, :lat, :lon, :status, :collect_interval, :uri)
    end

    def capability_params
      params.require(:data).permit(capabilities: [])
    end
end
