# frozen_string_literal: true

require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"

class ResourceUpdater
  TOPIC = 'resource_update'
  QUEUE = 'data-collector.resource.update'

  def initialize(consumers_size = 1, thread_pool = 1)
    @consumers_size = consumers_size
    @consumers = []
    @channel = Rails.configuration.worker_conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE, durable: true, auto_delete: false)
  end

  def perform
    @queue.bind(@topic, routing_key: '#.sensor.#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |_delivery_info, _properties, body|
        begin
          json = JSON.parse(body)
          resource_attributes = json.slice(
            'uuid',
            'status',
            'created_at',
            'updated_at',
            'capabilities'
          )

          update_resource(resource_attributes, json)
        rescue StandardError => e
          WORKERS_LOGGER.error("ResourcesUpdater::ResourceNotUpdated - #{e.message}")
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

  def update_resource(resource_attributes, json)
    resource = PlatformResource.find_by(uuid: json['uuid'])
    resource&.update!(resource_attributes)
    WORKERS_LOGGER.info("ResourcesUpdater::ResourceUpdated -  #{resource_attributes}")
  end
end
