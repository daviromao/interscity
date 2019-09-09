# frozen_string_literal: true

require 'rest-client'

module SmartCities
  module Notification
    def notify_resource(resource, params = {}, update = false)
      conn, channel = establish_connection

      key = build_resource_key(resource, params, update)
      message = JSON(resource.to_json)

      topic = if update
                channel.topic('resource_update')
              else # create
                channel.topic('resource_create')
              end

      topic.publish(message, routing_key: key)

      conn.close
    end

    def establish_connection
      conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
      conn.start
      channel = conn.create_channel

      [conn, channel]
    end

    def build_resource_key(resource, params, update)
      key = resource.uuid
      key += '.sensor' if resource.sensor?
      key += '.actuator' if resource.actuator?

      key += '.' + params.map { |k, _v| k.to_s }.join('.') if update && !params.empty?

      key
    end
  end
end
