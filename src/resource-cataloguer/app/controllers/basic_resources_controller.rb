# frozen_string_literal: true

require 'notification'
require 'resource_filter'

class BasicResourcesController < ApplicationController
  include SmartCities::Notification
  include SmartCities::ResourceFilter

  before_action :set_page_params, only: %i[index index_sensors index_actuators search]

  # GET /resources/search
  # Errors
  # => 422 unprocessable entity
  def search
    @resources = filtered_resources.paginate(page: @page, per_page: @per_page)
    render json: { resources: @resources }, status: :ok
  rescue StandardError => e
    render json: {
      error: "Error while searching resource: #{e.message}"
    }, status: :unprocessable_entity
  end

  # POST /resources
  # Errors
  # => 422 unprocessable entity
  def create
    resource = BasicResource.new(component_params)
    begin
      resource.save!
      if capability_params[:capabilities].present?
        add_capabilities_to_resource(capability_params[:capabilities], resource)
      end
      notify_resource(resource)
      render json: { data: resource.to_json }, status: :created, location: basic_resource_url(resource)
    rescue StandardError => e
      render json: { error: e }, status: :unprocessable_entity
    end
  end

  # GET /resources/
  def index
    render json: {
      resources: BasicResource.order('created_at DESC').page(@page).per_page(@per_page)
    }
  end

  # GET /resources/sensors
  def index_sensors
    render json: {
      resources: BasicResource.all_sensors.order('created_at DESC').page(@page).per_page(@per_page)
    }
  end

  # GET /resources/actuators
  def index_actuators
    render json: {
      resources: BasicResource.all_actuators.order('created_at DESC').page(@page).per_page(@per_page)
    }
  end

  # GET /resources/:uuid
  def show
    render json: { data: BasicResource.find_by!(uuid: params[:uuid]).to_json }
  rescue StandardError
    render json: {
      error: 'Resource not found'
    }, status: :not_found
  end

  # PUT /resources/:uuid
  def update
    resource = BasicResource.find_by(uuid: params[:uuid])
    begin
      update_resource_and_capabilities(resource)
      render json: { data: resource.to_json }, status: :ok
    rescue StandardError => e
      render json: {
        error: "Error while updating basic resource: #{e}"
      }, status: :unprocessable_entity
    end
  end

  private

  def search_params
    params.permit(:capability, :lat, :lon, :radius)
  end

  def simple_params
    params.permit(:status, :city, :neighborhood, :postal_code, :description, :uuid)
  end

  def component_params
    params.require(:data).permit(:description, :lat, :lon, :status, :collect_interval, :uri, :uuid)
  end

  def capability_params
    params.require(:data).permit(capabilities: [])
  end

  def set_page_params
    @page = params[:page] || 1
    @per_page = params[:per_page].nil? ? 40 : params[:per_page]
  end

  def filtered_resources
    resources = BasicResource.all
    resources = filter_capabilities resources, search_params
    resources = filter_position resources, search_params
    resources = filter_distance resources, search_params
    simple_params.each do |k, v|
      resources = filter_resources resources, k, v
    end

    resources
  end

  def add_capabilities_to_resource(capabilities, resource)
    capabilities.each do |cap|
      query = Capability.where(name: cap)
      raise CapabilityNotFound if query.empty?

      resource.capabilities << query.take
    end
  end

  def update_resource_and_capabilities(resource)
    resource.update!(component_params)

    if capability_params[:capabilities].present?
      resource.capabilities.destroy_all
      add_capabilities_to_resource(capability_params[:capabilities], resource)
    end

    notify_resource(resource, component_params.to_h, true)
  end
end
