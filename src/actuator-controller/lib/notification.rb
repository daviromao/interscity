# frozen_string_literal: true

module SmartCities
  module Notifier
    @conn = nil
    @channel = nil

    def self.connect
      if @conn.nil? || @conn.closed?
        @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
        @conn.start
      end
      @channel = @conn.create_channel if @channel.nil? || @channel.closed?
    end

    def setup_connection
      SmartCities::Notifier.connect
    end

    def notify_command_request(command = self)
      setup_connection if @conn.nil? || @conn.closed?
      key = command.uuid
      key = key + '.' + command.capability
      topic = @channel.topic('resource.actuate.create')
      message = command.to_json
      topic.publish(message, routing_key: key)
    end
  end
end
