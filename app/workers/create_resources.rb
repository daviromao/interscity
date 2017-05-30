require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"

class CreateResources
  include Sidekiq::Worker
  sidekiq_options queue: 'create_resources', backtrace: true

  TOPIC = 'resource_create'
  QUEUE = 'data_collection_resource_create'

  def perform
    conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    conn.start
    channel = conn.create_channel
    topic = channel.topic(TOPIC)
    queue = channel.queue(QUEUE)
    queue.bind(topic, routing_key: '#.sensor.#')

    begin
      queue.subscribe(:block => true) do |delivery_info, properties, body|
        routing_keys = delivery_info.routing_key.split('.')
        json = JSON.parse(body)
        resource_attributes = json.slice(
          'uri',
          'uuid',
          'status',
          'collect_interval',
          'created_at',
          'updated_at',
          'capabilities'
        )
        resource = PlatformResource.new(resource_attributes)
        resource.save!

        logger.info("ResourcesCreate: Resource Created: #{resource_attributes}")
      end
    rescue Exception => e
      logger.error("ResourcesCreate: channel closed - #{e.message}")
      conn.close
      CreateResources.perform_in(2.seconds)
    end
  end
end
