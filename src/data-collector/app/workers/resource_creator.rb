require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"

class ResourceCreator
  TOPIC = 'resource_create'
  QUEUE = 'data-collector.resource.create'

  def initialize(consumers_size = 1, thread_pool = 1)
    @consumers_size = consumers_size
    @consumers = []
    @channel = $conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE, durable: true, auto_delete: false)
  end

  def perform
    @queue.bind(@topic, routing_key: '#.sensor.#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |delivery_info, properties, body|
        begin
          routing_keys = delivery_info.routing_key.split('.')
          json = JSON.parse(body)
          resource_attributes = json.slice(
            'uuid',
            'status',
            'created_at',
            'updated_at',
            'capabilities'
          )
          resource = PlatformResource.new(resource_attributes)
          resource.save!

          WORKERS_LOGGER.info("ResourceCreator::ResourceCreated - #{resource_attributes}")
        rescue StandardError => e
          WORKERS_LOGGER.error("ResourcesCreator::ResourceNotCreated - #{e.message}")
        end
      end
    end
  end

  def cancel
    @consumers.each do |consumer|
      @consumer.cancel
    end
    @channel.close
  end
end
