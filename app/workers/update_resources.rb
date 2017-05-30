require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"

class UpdateResources
  include Sidekiq::Worker
  sidekiq_options queue: 'update_resources', backtrace: true

  TOPIC = 'resource_update'
  QUEUE = 'actuator_controller_resource_update'

  def initialize
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
  end

  def perform
    @queue.bind(topic, routing_key: '#.actuator.#')

    begin
      @queue.subscribe(:block => true) do |delivery_info, properties, body|
        routing_keys = delivery_info.routing_key.split('.')
        json = JSON.parse(body)
        resource_attributes = json.slice(
          'uuid',
          'status',
          'created_at',
          'updated_at',
          'capabilities'
        )

        update_resource(resource_attributes, json)
      end
    rescue Exception => e
      logger.error("UpdateResources: channel closed - #{e.message}")
      @conn.close
      UpdateResources.perform_in(2.seconds)
    end
  end

  private

  def update_resource(resource_attributes, json)
    resource = PlatformResource.find_by(uuid: json['uuid'])
    resource.update!(resource_attributes) if resource
    logger.info("ResourcesUpdate: Resource Updated: #{resource_attributes}")
  rescue Mongoid::Errors::Validations => invalid
    logger.error("ResourcesUpdate: Attempt to store resource: #{invalid.record.errors}")
  end
end
