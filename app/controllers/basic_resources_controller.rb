require 'notification'
require 'resource_filter'

class BasicResourcesController < ApplicationController
  include SmartCities::Notification
  include SmartCities::ResourceFilter

  # GET /resources/search
  # Errors
  # => 422 unprocessable entity
  def search
    response = []
    begin
      @resources = BasicResource.all
      @resources = filter_capabilities @resources, search_params
      @resources = filter_position @resources, search_params
      @resources = filter_distance @resources, search_params
      simple_params.each do |k,v|
        @resources = filter_resources @resources, k, v
      end
      @resources.each do |resource|
        response << {uuid: resource.uuid, lat: resource.lat, lon: resource.lon, collect_interval: resource.collect_interval}
      end
      render json: {resources: response}, status: 200
    rescue
      render json: {
        error: "Error while searching resource"
      }, status: 422
    end
  end

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
      notify_resource(resource)
      render json: {data: resource.to_json}, status: 201, location: basic_resource_url(resource)
    rescue
      render json: {
        error: "Error while creating basic resource"
      }, status: 422
    end
  end

  # GET /resources/
  def index
    render json: {resources: BasicResource.all}
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
  def /show
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
        resource.capabilities.destroy_all
        capability_params[:capabilities].each do |cap|
          query = Capability.where(name: cap)
          raise if query.empty?
          resource.capabilities << query.take
        end
      end
      notify_resource(resource, update: true)
    rescue
      render json: {
        error: "Error while updating basic resource"
      }, status: 422
    end
  end

  private

    def search_params
      params.permit(:capability, :lat, :lon, :radius)
    end

    def simple_params
      params.permit(:status, :city, :neighborhood, :postal_code)
    end

    def component_params
      params.require(:data).permit(:description, :lat, :lon, :status, :collect_interval, :uri)
    end

    def capability_params
      params.require(:data).permit(capabilities: [])
    end

end
