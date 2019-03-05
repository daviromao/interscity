require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"
require "#{File.dirname(__FILE__)}/../models/sensor_value"
require "#{File.dirname(__FILE__)}/../models/last_sensor_value"

class DataReceiver
  TOPIC = 'data_stream'
  QUEUE = 'data-collector.data.stream'

  def initialize(consumers_size = 1, thread_pool = 1)
    @consumers_size = consumers_size
    @consumers = []
    @channel = $conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE, durable: true, auto_delete: false)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |delivery_info, properties, body|
        begin
          routing_keys = delivery_info.routing_key.split('.')
          uuid = routing_keys.first
          resource = PlatformResource.find_by(uuid: uuid)
          if resource.nil?
            WORKERS_LOGGER.error("DataReceiver::ResourceNotFound = Could not find resource #{uuid}")
          end

          capability = routing_keys[1]
          unless resource.capabilities.include? capability
            resource.capabilities << capability
            WORKERS_LOGGER.info("DataReceiver::CapabilityAssociation -  #{capability} associated with resource #{uuid}")
          end

          create_sensor_value(resource, capability, body)
          WORKERS_LOGGER.info("DataReceiver::DataCreated - #{resource.uuid} - #{capability}")
        rescue StandardError => e
          WORKERS_LOGGER.error("DataReceiver::DataNotCreated - #{e.message}")
        end
      end
    end
  end

  private

  def create_sensor_value(resource, capability, body)
    if resource && capability
      json = JSON.parse(body)
      attributes = {uuid: resource.uuid,
                    capability: capability,
                    platform_resource_id: resource.id}
      attributes.merge! json
      attributes["date"] = attributes["timestamp"] unless attributes["date"]
      attributes.delete("timestamp")
      value = SensorValue.new(attributes)
      if !value.save
        raise "Cannot save: #{value.inspect} with body #{body} and the errors: #{value.errors.messages}"
      end
    end
  end
end
