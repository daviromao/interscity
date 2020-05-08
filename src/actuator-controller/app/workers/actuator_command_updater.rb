# frozen_string_literal: true

require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/actuator_command"

class ActuatorCommandUpdater
  TOPIC = 'resource.actuate.status'
  QUEUE = 'actuator_controller.resource.actuation.status'

  def initialize(consumers_size = 1, thread_pool = 1)
    @consumers_size = consumers_size
    @consumers = []
    @channel = Rails.configuration.worker_conn.create_channel(nil, thread_pool)
    @channel.prefetch(2)
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE, durable: true, auto_delete: false)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    @consumers_size.times do
      @consumers << @queue.subscribe(block: false) do |_delivery_info, _properties, body|
        begin
          json = JSON.parse(body)
          command = ::ActuatorCommand.find(json['command_id'])
          command.status = json['status']
          command.save!

          WORKERS_LOGGER.info(
            "ActuatorCommandUpdater::CommandUpdated - command=#{json['command_id']}&status=#{json['status']}"
          )
        rescue StandardError => e
          WORKERS_LOGGER.error("ActuatorCommandUpdater::CommandNotUpdated - #{e.message}")
        end
      end
    end
  end

  def cancel
    @consumers.each(&:cancel)
    @channel.close
  end
end
