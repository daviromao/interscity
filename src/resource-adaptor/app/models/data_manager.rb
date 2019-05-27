# frozen_string_literal: true

require 'bunny'
require 'json'

class DataManager
  include Singleton

  def initialize
    setup
    ObjectSpace.define_finalizer(self, self.class.finalize)
  end

  def self.finalize
    proc do
      @channel.close
      @conn.close
    end
  end

  def publish_resource_data(uuid, capability, value)
    setup if @conn.closed?
    message = JSON(value)
    key = uuid + '.' + capability
    key += '.location' if value.key?('location')
    topic = @channel.topic('data_stream')
    topic.publish(message, routing_key: key)
  end

  def publish_actuation_command_status(uuid, capability, command_id, status)
    setup if @conn.closed?
    message = JSON(command_id: command_id, status: status)
    key = uuid + '.' + capability
    topic = @channel.topic('resource.actuate.status')
    topic.publish(message, routing_key: key)
  end

  def setup
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
  end
end
