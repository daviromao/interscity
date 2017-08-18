require 'bunny'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/../models/basic_resource"


class LocationUpdater
  TOPIC = 'data_stream'
  QUEUE = 'resource_cataloguer_data_stream'

  def initialize(consumers_size = 1, thread_pool = 1, capability_name = 'location')
    @consumers_size = consumers_size
    @consumers = []
    @channel = $conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
    @capability = capability_name
  end

  def perform
    @queue.bind(@topic, routing_key: "#." + @capability + ".#")

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |delivery_info, properties, body|
        begin
          routing_keys = delivery_info.routing_key.split('.')

          uuid = routing_keys[0]
          capability = routing_keys[1]
          value = JSON.parse(body)

          resource_attributes = {
            lat: value["value"][0],
            lon: value["value"][1]
          }
          update_location(resource_attributes, uuid)

        rescue StandardError => e
          WORKERS_LOGGER.error("LocationUpdate::ResourceNotUpdated - #{e.message}")
        end
      end
    end
  end

  private

  def update_location(resource_attributes, uuid)
    resource = BasicResource.find_by(uuid: uuid)
    if resource
      resource.update!(resource_attributes)
      WORKERS_LOGGER.info("LocationUpdate::ResourceUpdated - #{resource_attributes}")
    else
      WORKERS_LOGGER.error("LocationUpdate::ResourceNotFound - #{uuid}")
    end
  end
end
