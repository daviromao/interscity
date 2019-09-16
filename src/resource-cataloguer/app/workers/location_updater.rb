# frozen_string_literal: true

require 'bunny'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/../models/basic_resource"

class LocationUpdater
  TOPIC = 'data_stream'
  QUEUE = 'resource_cataloguer_data_stream'

  def initialize(consumers_size = 1, thread_pool = 1, location_attr = 'location')
    @consumers_size = consumers_size
    @consumers = []
    @channel = Rails.configuration.worker_conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
    @location_attr = location_attr
  end

  def perform
    @queue.bind(@topic, routing_key: '#.' + @location_attr + '.#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |delivery_info, _properties, body|
        begin
          routing_keys = delivery_info.routing_key.split('.')
          uuid = routing_keys[0]
          resource_attributes = parse_latlong(body)

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

  def parse_latlong(body)
    value = JSON.parse(body)
    lat = value['location']['lat']
    lon = value['location']['lon']

    raise 'Could not read latitude or longitude data' if lat.blank? || lon.blank?

    { lat: lat, lon: lon }
  end
end
