require 'bunny'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/../models/basic_resource"


class LocationUpdate

  TOPIC = 'data_stream'
  QUEUE = 'resource_cataloguer_resource_update'

  def initialize
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    begin
      @queue.subscribe(:block => false) do |delivery_info, properties, body|
        puts delivery_info, body

        routing_keys = delivery_info.routing_key.split('.')

        uuid = routing_keys[0]
        capability = routing_keys[1]
        value = JSON.parse(body)

        if capability == 'location'
          resource_attributes = value.slice(
            'lon',
            'lat',
          )
          update_location(resource_attributes, uuid)
        end

      end
    rescue Exception => e
      LOGGER.error("LocationUpdate: channel closed - #{e.message}")
      @conn.close
      LocationUpdate.perform_in(2.seconds)
    end
  end

  private

  def update_location(resource_attributes, uuid)

    resource = BasicResource.find_by(uuid: uuid)
    resource.update!(resource_attributes) if resource

    LOGGER.info("LocationUpdate: Resource Updated: #{resource_attributes}")
  rescue PG::Error => err
    error =  [
        err.result.error_field( PG::Result::PG_DIAG_SEVERITY ),
        err.result.error_field( PG::Result::PG_DIAG_SQLSTATE ),
        err.result.error_field( PG::Result::PG_DIAG_MESSAGE_PRIMARY ),
        err.result.error_field( PG::Result::PG_DIAG_MESSAGE_DETAIL ),
        err.result.error_field( PG::Result::PG_DIAG_MESSAGE_HINT ),
        err.result.error_field( PG::Result::PG_DIAG_STATEMENT_POSITION ),
        err.result.error_field( PG::Result::PG_DIAG_INTERNAL_POSITION ),
        err.result.error_field( PG::Result::PG_DIAG_INTERNAL_QUERY ),
        err.result.error_field( PG::Result::PG_DIAG_CONTEXT ),
        err.result.error_field( PG::Result::PG_DIAG_SOURCE_FILE ),
        err.result.error_field( PG::Result::PG_DIAG_SOURCE_LINE ),
        err.result.error_field( PG::Result::PG_DIAG_SOURCE_FUNCTION ),
    ]
    LOGGER_DB.error("LocationUpdate: Attempt to store resource: #{error.to_s}")
  end
end
