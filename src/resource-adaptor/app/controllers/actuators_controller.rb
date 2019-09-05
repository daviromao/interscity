# frozen_string_literal: true

class ActuatorsController < ApplicationController
  before_action :set_subscription, only: %i[update destroy show]

  # GET /subscriptions?uuid=""
  def index
    @subscriptions = Subscription.all
    @subscriptions = @subscriptions.where(uuid: params['uuid']) if params['uuid']

    render json: { subscriptions: @subscriptions }, status: :ok
  end

  # GET /subscriptions/:id
  def show
    render json: { subscription: @subscription }, status: :ok
  end

  # POST /subscriptions/
  def subscribe
    @subscription = Subscription.new(subscription_params)

    unless @subscription.valid?
      render json: { error: @subscription.errors.full_messages }, status: :unprocessable_entity
      return
    end

    return unless valid_capabilities?(@subscription)

    @subscription.save
    render json: { subscription: @subscription }, status: :created
  end

  # PUT /subscriptions/:id
  def update
    @subscription.assign_attributes(subscription_params)

    unless @subscription.valid?
      render json: { error: @subscription.errors.full_messages }, status: :unprocessable_entity
      return
    end

    return unless valid_capabilities?(@subscription)

    @subscription.save
    render json: { subscription: @subscription }, status: :ok
  end

  # DELETE /subscriptions/:id
  def destroy
    @subscription.destroy
    render head: :no_content, status: :no_content
  end

  private

  def subscription_params
    params.require(:subscription).permit(:uuid, :url, capabilities: [])
  end

  def set_subscription
    @subscription = Subscription.find(params['id'])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Subscription not found' }, status: :not_found
    nil
  end

  def valid_capabilities?(subscription)
    available_capabilities = fecth_resource_capabilities(subscription)
    return false unless available_capabilities

    match_capabilities = available_capabilities & subscription.capabilities
    if match_capabilities.blank?
      render(
        json: {
          error: "This resource does not have these capabilities: #{subscription.capabilities - match_capabilities}"
        },
        status: :not_found
      )
      return false
    end

    true
  end

  def fecth_resource_capabilities(subscription)
    response = Platform::ResourceManager.get_resource(subscription.uuid)
    if response.nil?
      render json: { error: 'Resource Cataloguer service is unavailable' }, status: :service_unavailable
      return false
    elsif response.code != 200
      render json: response.body, status: response.code
      return false
    end

    JSON.parse(response.body)['data']['capabilities']
  end
end
