require 'bunny'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/../models/basic_resource"


class UpdateResources
  include Sidekiq::Worker
  sidekiq_options queue: 'update_resources_cataloguer', backtrace: true

  TOPIC = 'data_stream' # Data_stream
  QUEUE = 'resource_cataloguer_resource_update' # something

  def initialize #Algo assim
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    begin
      @queue.subscribe(:block => true) do |delivery_info, properties, body|
        puts delivery_info, body

        # routing_keys = delivery_info.routing_key.split('.')
        # uuid = routing_keys[0]
        # capability = routing_keys[1]
        # value = JSON.parse(body)

        # if capability == 'location'
        #   resource_attributes = value.slice(
        #     'lon',
        #     'lat',
        #   )
        #   update_location(resource_attributes, uuid)
        # end

      end
    rescue Exception => e
      logger.error("UpdateResources: channel closed - #{e.message}")
      @conn.close
      UpdateResources.perform_in(2.seconds)
    end
  end

  private

  def update_location(resource_attributes, uuid)

    resource = BasicResource.find_by(uuid: uuid)
    resource.update!(resource_attributes) if resource

    logger.info("ResourcesUpdate: Resource Updated: #{resource_attributes}")
  rescue Mongoid::Errors::Validations => invalid
    logger.error("ResourcesUpdate: Attempt to store resource: #{invalid.record.errors}")
  end
end
