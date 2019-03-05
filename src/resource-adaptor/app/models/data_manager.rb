# encoding: utf-8

require 'bunny'
require 'json'

class DataManager
  include Singleton

  def initialize
    self.setup
    ObjectSpace.define_finalizer( self, self.class.finalize() )
  end

  def self.finalize
    proc do
      @channel.close
      @conn.close
    end
  end

  def publish_resource_data(uuid, capability, value)
    self.setup if @conn.closed?
    message = JSON(value)
    key = uuid + '.' + capability
    if value.has_key?("location")
      key = key + '.location'
    end
    topic = @channel.topic('data_stream')
    topic.publish(message, routing_key: key)
  end

  def publish_actuation_command_status(uuid, capability, command_id, status)
    self.setup if @conn.closed?
    message = JSON({command_id: command_id, status: status})
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
