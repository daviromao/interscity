# frozen_string_literal: true

require 'rails_helper'
require 'notification'
require 'bunny'

RSpec.describe SmartCities::Notifier do
  let(:test_class) do
    Class.new do
      include SmartCities::Notifier
      attr_accessor :conn, :channel
    end
  end
  let(:instance) { test_class.new }

  describe 'instance methods' do
    describe 'setup_connection' do
      it 'is expected to connect using the module method' do
        expect(SmartCities::Notifier).to receive(:connect)
        instance.setup_connection
      end
    end

    describe 'notify_command_request' do
      let(:channel) { double('channel') }
      let(:command) { FactoryGirl.build(:actuator_command, uuid: 'uuid', capability: 'temperature') }
      let(:uuid) { 'key' }
      let(:topic) { double('topic') }

      context 'with a nil connection' do
        before do
          instance.conn = nil
          instance.channel = channel
          allow(instance).to receive(:setup_connection)
          allow(channel).to receive(:topic).and_return(topic)
          allow(topic).to receive(:publish)

          instance.notify_command_request(command)
        end

        it 'is expected to setup the connection' do
          expect(instance).to have_received(:setup_connection)
        end

        it 'is expected to publish the message' do
          expect(topic).to have_received(:publish)
            .with(command.to_json, routing_key: 'uuid.temperature')
        end
      end
    end
  end

  describe 'connect' do
    let(:conn) { double('conn') }
    let(:channel) { double('channel') }
    let(:rabbitmq_host) { 'rabbitmq' }
    let(:services_config) { { 'services' => { 'rabbitmq' => rabbitmq_host } } }

    before do
      allow(conn).to receive(:start)
      allow(conn).to receive(:create_channel)
      allow(Bunny).to receive(:new).and_return(conn)

      described_class.instance_variable_set('@conn', conn)
    end

    after do
      described_class.instance_variable_set('@conn', nil)
    end

    context 'with a nil/closed connection' do
      before do
        allow(conn).to receive(:nil?).and_return(true)
        allow(conn).to receive(:closed?).and_return(false)

        SmartCities::Notifier::SERVICES_CONFIG = services_config
        described_class.connect
      end

      it 'is expected to call Bunny' do
        expect(Bunny).to have_received(:new).with(hostname: rabbitmq_host)
      end

      it 'is expected to start the connection' do
        expect(conn).to have_received(:start)
      end

      it 'is expected to create the channel' do
        expect(conn).to have_received(:create_channel)
      end
    end

    context 'with an existing connection' do
      before do
        allow(conn).to receive(:nil?).and_return(false)
        allow(conn).to receive(:closed?).and_return(false)

        described_class.connect
      end

      it 'is expected to call Bunny' do
        expect(Bunny).not_to have_received(:new)
      end

      it 'is expected to start the connection' do
        expect(conn).not_to have_received(:start)
      end
    end
  end
end
