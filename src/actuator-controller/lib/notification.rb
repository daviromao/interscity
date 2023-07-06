# frozen_string_literal: true
require 'bunny'

module SmartCities
  module Notifier
    attr_reader :conn, :channel

    def connect
      @conn ||= Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
      @conn.start unless @conn.open?
      @channel ||= @conn.create_channel
    end

    def setup_connection
      connect
    end

    def notify_command_request(command = self)
      setup_connection
      key = "#{command.uuid}.#{command.capability}"
      topic = channel.topic('resource.actuate.create')
      message = command.to_json
      topic.publish(message, routing_key: key)
    end

    module_function :connect, :setup_connection, :notify_command_request
  end
end
