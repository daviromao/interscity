class PlatformResourcesController < ApplicationController
  before_action :find_platform_resource, only: [:update]

  def create
    platform_resource = PlatformResource.new(platform_resource_params)
    begin
      if platform_resource.save
        capabilities = get_capabilities
        assotiate_capability_with_resource(capabilities, platform_resource)
        render json: { data: platform_resource }, status: 201
      else
        render json: { error: 'Internal Server Error' }, status: 500
      end
    rescue ActiveRecord::RecordNotUnique
      render json: { error: 'Duplicated uuid' }, status: 400
    end
  end

  def update
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource
      @retrieved_resource.update!(platform_resource_params)

      capabilities = get_capabilities
      remove_needed_capabilities(capabilities, @retrieved_resource)

      assotiate_capability_with_resource(capabilities, @retrieved_resource)

      render json: { data: @retrieved_resource }, status: 201

      # TODO: Restart data collect thread
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not found' }, status: 404
    end
  end

  private

    def platform_resource_params
      params.require(:data).permit(:uri, :uuid, :status, :collect_interval)
    end

    def capability_params
      params.require(:data).permit(capabilities: [])
    end

    def find_platform_resource
      @retrieved_resource = PlatformResource.find_by_uuid(params[:uuid])
    end

    def get_capabilities
      capability_params[:capabilities]
    end

    def assotiate_capability_with_resource(capabilities, resource)
      if capabilities.kind_of? Array
        capabilities.each do |capability_name|
          # This block ensures thread safe
          # TODO: use semaphore
          begin
            capability = Capability.find_by(name: capability_name)
            capability = Capability.create(name: capability_name) if capability.nil?
          rescue ActiveRecord::RecordNotUnique
            capability = Capability.find_by(name: capability_name)
          end

          unless resource.capabilities.include?(capability)
            resource.capabilities << capability
          end
        end
      end
    end

    def remove_needed_capabilities(capabilities, resource)
      # If no capabilities are present inside hash, just remove all
      if capabilities.nil?
        resource.capabilities.delete_all
      else
        rm = resource.capabilities.where("name not in (?)", capabilities)
        resource.capabilities.delete(rm)
      end
    end

end
