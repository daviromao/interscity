# frozen_string_literal: true

require 'rails_helper'
require 'workers/worker_helper'

RSpec.describe DataReceiver do
  let(:channel) { double('channel') }
  let(:queue) { double('queue') }

  before do
    allow(Rails).to receive_message_chain(:configuration, :worker_conn, :create_channel).and_return(channel)
    allow(channel).to receive(:prefetch)
    allow(channel).to receive(:topic)
    allow(channel).to receive(:queue).and_return(queue)
  end

  include_examples 'resource_init with queue parameters',
                   described_class::QUEUE,
                   durable: true,
                   auto_delete: false

  describe 'perform' do
    let(:body) { double('body') }
    let(:delivery_info) { double('delivery_info') }

    before do
      allow(queue).to receive(:bind)
      allow(queue).to receive(:subscribe) { |&block| block.call(delivery_info, nil, body) }

      WORKERS_LOGGER = double('workers_logger')
      allow(WORKERS_LOGGER).to receive(:info)
      allow(WORKERS_LOGGER).to receive(:error)
    end

    context 'with an error' do
      before do
        expect(subject).to receive(:find_resource_and_capability)
          .with(delivery_info) { raise StandardError }

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to log an error' do
        expect(WORKERS_LOGGER).to have_received(:error).with(
          'DataReceiver::DataNotCreated - StandardError'
        )
      end
    end

    context 'with succesfully parsing the json' do
      let(:resource_attributes) { 'attributes' }
      let(:resource) { double('resource', uuid: 'uuid') }
      let(:capability) { 'temperature' }

      before do
        allow(subject).to receive(:find_resource_and_capability)
          .and_return([resource, capability])
        allow(subject).to receive(:create_sensor_value)

        subject.perform
      end

      it 'is expected to find the resource and capability' do
        expect(subject).to have_received(:find_resource_and_capability)
          .with(delivery_info)
      end

      it 'is expected to create the sensor value' do
        expect(subject).to have_received(:create_sensor_value)
          .with(resource, capability, body)
      end

      it 'is expected to log the sensor value creation' do
        expect(WORKERS_LOGGER).not_to have_received(:error)
        expect(WORKERS_LOGGER).to have_received(:info).with(
          "DataReceiver::DataCreated - #{resource.uuid} - #{capability}"
        )
      end
    end
  end

  describe 'private methods' do
    describe 'create_sensor_value' do
      let(:resource) { double('resource', uuid: 'uuid', id: 1) }
      let(:capability) { 'temperature' }
      let(:body) { '{}' }
      let(:json) { { 'date' => '10' } }

      before do
        allow(JSON).to receive(:parse).and_return(json)
      end

      context 'with a successful creation' do
        let(:sensor_value) { double('value', save: true) }

        before do
          allow(SensorValue).to receive(:new).and_return(sensor_value)
          subject.send(:create_sensor_value, resource, capability, body)
        end

        it 'is expected to stuff' do
          expect(JSON).to have_received(:parse).with(body)
        end
      end

      context 'with an error' do
        let(:sensor_value) { double('value', save: false) }

        before do
          allow(SensorValue).to receive(:new).and_return(sensor_value)
        end

        it 'is expected to raise an error' do
          expect do
            subject.send(:create_sensor_value, resource, capability, body)
          end.to raise_error
        end
      end
    end

    describe 'find_resource_and_capability' do
      let(:uuid) { 'uuid' }
      let(:capability) { 'temperature' }
      let(:delivery_info) { double('delivery_info', routing_key: "#{uuid}.#{capability}") }
      let(:resource) do
        double('resource', uuid: 'uuid', id: 1, capabilities: [capability])
      end

      before do
        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:info)
        allow(WORKERS_LOGGER).to receive(:error)

        allow(PlatformResource).to receive(:find_by).and_return(resource)
      end

      context 'with an existing resource' do
        before do
          @result = subject.send(:find_resource_and_capability, delivery_info)
        end

        it 'is expected to look for the resource' do
          expect(PlatformResource).to have_received(:find_by).with(uuid: uuid)
        end

        it 'is expected to return a pair with the resource and capability' do
          expect(@result).to eq([resource, capability])
        end
      end

      context 'with a new capability for the resource' do
        let(:new_capability) { 'pressure' }
        let(:delivery_info) { double('delivery_info', routing_key: "#{uuid}.#{new_capability}") }

        before do
          @result = subject.send(:find_resource_and_capability, delivery_info)
        end

        it 'is expected to log the capability association' do
          expect(WORKERS_LOGGER).to have_received(:info).with(
            "DataReceiver::CapabilityAssociation -  #{new_capability} associated with resource #{uuid}"
          )
        end

        it 'is expected to return a pair with the resource and capability' do
          expect(@result).to eq([resource, new_capability])
        end
      end

      context 'with a not found resource' do
        before do
          expect(PlatformResource).to receive(:find_by).and_return(nil)
        end

        it 'is expected to log and raise an error' do
          expect { subject.send(:find_resource_and_capability, delivery_info) }.to raise_error
          expect(WORKERS_LOGGER).to have_received(:error).with(
            "DataReceiver::ResourceNotFound = Could not find resource #{uuid}"
          )
        end
      end
    end
  end
end
