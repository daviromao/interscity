# frozen_string_literal: true

require 'bunny'
require 'rubygems'
require 'json'

class ActuatorCommandNotifier
  TOPIC = 'resource.actuate.create'
  QUEUE = 'resource_adaptor.resource.actuation'

  def initialize(consumers_size = 1, thread_pool = 1)
    @consumers_size = consumers_size
    @consumers = []
    @channel = Rails.configuration.worker_conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE, durable: true, auto_delete: false)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |_delivery_info, _properties, body|
        begin
          json = JSON.parse(body)
          uuid = json['uuid']
          capability = json['capability']

          raise 'UUID and Capability not provided' unless uuid && capability

          schedule_webhooks(uuid, json, capability, body)
        rescue StandardError => e
          WORKERS_LOGGER.error("AcutatorCommandNotifier::CommandNotProcessed - #{e.message}")
        end
      end
    end
  end

  def cancel
    @consumers.each do |_consumer|
      @consumer.cancel
    end
    @channel.close
  end

  private

  def schedule_webhooks(uuid, json, capability, body)
    ::Subscription.where(uuid: uuid, active: true).each do |subscription|
      if subscription.capabilities.include? capability
        ::WebHookCaller.perform_async(subscription.id, subscription.url, body)
        WORKERS_LOGGER.info("AcutatorCommandNotifier::CommandReceived - #{json}")
      end
    end
  end
end
