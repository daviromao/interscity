# frozen_string_literal: true

require 'rest-client'

module SmartCities
  module Notification
    def notify_resource(resource, params = {}, update = false)
      conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
      conn.start
      channel = conn.create_channel
      key = resource.uuid
      key += '.sensor' if resource.sensor?
      key += '.actuator' if resource.actuator?

      if update
        topic = channel.topic('resource_update')
        message = JSON(resource.to_json)
        key = key + '.' + params.map { |k, _v| k.to_s }.join('.') unless params.empty?
        topic.publish(message, routing_key: key)
      else # create
        topic = channel.topic('resource_create')
        message = JSON(resource.to_json)
        topic.publish(message, routing_key: key)
      end
      conn.close
    end
  end
end
