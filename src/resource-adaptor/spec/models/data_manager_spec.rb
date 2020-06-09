# frozen_string_literal: true

require 'rails_helper'
require 'unit_helper'

RSpec.describe DataManager do
  let(:channel) { double('channel') }
  let(:connection) { double('connection', create_channel: channel) }
  let(:subject) { described_class.instance }
  let(:topic) { double('topic') }

  before do
    allow(Bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:start)

    subject
  end

  describe 'finalize' do
    before do
      described_class.instance_variable_set('@conn', connection)
      described_class.instance_variable_set('@channel', channel)
    end

    it 'is expected to close the channel and the connection' do
      expect(channel).to receive(:close)
      expect(connection).to receive(:close)

      described_class.finalize.call
    end
  end

  describe 'publish_resource_data' do
    let(:uuid) { 'uuid' }
    let(:capability) { 'temperature' }
    let(:value) { { a: 1 } }
    let(:message) { '{"a":1}' }
    let(:key) { "#{uuid}.#{capability}" }

    before do
      subject.instance_variable_set('@conn', connection)
      subject.instance_variable_set('@channel', channel)
      allow(connection).to receive(:closed?).and_return(false)
      allow(channel).to receive(:topic).and_return(topic)
      allow(topic).to receive(:publish)

      subject.publish_resource_data(uuid, capability, value)
    end

    it 'is expected to check if the connection is open' do
      expect(connection).to have_received(:closed?)
    end

    it 'is expected to get the right topic' do
      expect(channel).to have_received(:topic).with('data_stream')
    end

    it 'is expected to publish the message' do
      expect(topic).to have_received(:publish).with(message, routing_key: key)
    end
  end

  describe 'publish_actuation_command_status' do
    let(:uuid) { 'uuid' }
    let(:capability) { 'temperature' }
    let(:command_id) { 'id' }
    let(:status) { 'status' }
    let(:message) { '{"command_id":"id","status":"status"}' }
    let(:key) { "#{uuid}.#{capability}" }

    before do
      subject.instance_variable_set('@conn', connection)
      subject.instance_variable_set('@channel', channel)
      allow(connection).to receive(:closed?).and_return(false)
      allow(channel).to receive(:topic).and_return(topic)
      allow(topic).to receive(:publish)

      subject.publish_actuation_command_status(uuid, capability, command_id, status)
    end

    it 'is expected to check if the connection is open' do
      expect(connection).to have_received(:closed?)
    end

    it 'is expected to get the right topic' do
      expect(channel).to have_received(:topic).with('resource.actuate.status')
    end

    it 'is expected to publish the message' do
      expect(topic).to have_received(:publish).with(message, routing_key: key)
    end
  end

  describe 'setup' do
    it 'is expected to create a connection and create a channel' do
      expect(Bunny).to receive(:new).with(hostname: SERVICES_CONFIG['services']['rabbitmq'])
      expect(connection).to receive(:start)
      expect(connection).to receive(:create_channel)

      subject.setup
    end
  end
end
