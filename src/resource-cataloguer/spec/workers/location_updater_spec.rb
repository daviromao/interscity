# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationUpdater do
  let(:channel) { double('channel') }
  let(:queue) { double('queue') }
  let(:topic) { double('topic') }
  let(:subject) { described_class.new }

  before do
    allow(Rails).to receive_message_chain(:configuration, :worker_conn, :create_channel).and_return(channel)
    allow(channel).to receive(:prefetch)
    allow(channel).to receive(:topic).and_return(topic)
    allow(channel).to receive(:queue).and_return(queue)
  end

  describe 'initialize' do
    before do
      subject
    end

    it 'is expected to create channel' do
      expect(Rails.configuration.worker_conn).to have_received(:create_channel).with(nil, 1)
    end
  end

  describe 'perform' do
    let(:delivery_info) { double('delivery_info') }
    let(:body) { double('body') }

    before do
      allow(queue).to receive(:bind)
      allow(queue).to receive(:subscribe) { |&block| block.call(delivery_info, nil, body) }

      WORKERS_LOGGER = double('workers_logger')
      allow(WORKERS_LOGGER).to receive(:error)
    end

    context 'with succesfully updating the location' do
      let(:resource_attributes) { 'attributes' }
      let(:command) { instance_double(ActuatorCommand) }
      let(:uuid) { 'uuid' }

      before do
        allow(delivery_info).to receive(:routing_key).and_return(uuid)
        allow(subject).to receive(:parse_latlong).and_return(resource_attributes)
        allow(subject).to receive(:update_location)

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to parse the resource coordinates' do
        expect(subject).to have_received(:parse_latlong).with(body)
      end

      it 'is expected to update the location' do
        expect(subject).to have_received(:update_location)
          .with(resource_attributes, uuid)
      end
    end

    context 'with an error when processing the delivery' do
      before do
        expect(delivery_info).to receive(:routing_key) { raise StandardError }

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to log an error' do
        expect(WORKERS_LOGGER).to have_received(:error).with(
          'LocationUpdate::ResourceNotUpdated - StandardError'
        )
      end
    end
  end

  describe 'private methods' do
    describe 'update_location' do
      let(:uuid) { double('uuid') }
      let(:resource_attributes) { double('attributes') }
      let(:resource) { double('resource') }

      before do
        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:info)
        allow(WORKERS_LOGGER).to receive(:error)
      end

      context 'with an existing resource' do
        before do
          allow(BasicResource).to receive(:find_by).and_return(resource)
          allow(resource).to receive(:update!)

          subject.send(:update_location, resource_attributes, uuid)
        end

        it 'is expected to search the resource by uuid' do
          expect(BasicResource).to have_received(:find_by).with(uuid: uuid)
        end

        it 'is expected to update the resource' do
          expect(resource).to have_received(:update!).with(resource_attributes)
        end

        it 'is expected to log the resource update' do
          expect(WORKERS_LOGGER).to have_received(:info).with(
            "LocationUpdate::ResourceUpdated - #{resource_attributes}"
          )
        end
      end

      context 'with a not found resource' do
        before do
          expect(BasicResource).to receive(:find_by).and_return(nil)

          subject.send(:update_location, resource_attributes, uuid)
        end

        it 'is expected to log the resource update error' do
          expect(WORKERS_LOGGER).to have_received(:error).with(
            "LocationUpdate::ResourceNotFound - #{uuid}"
          )
        end
      end
    end

    describe 'parse_latlong' do
      let(:body) { 'body' }
      let(:lat) { 2 }
      let(:lon) { 3 }
      let(:parsed_body) { { 'location' => { 'lat' => lat, 'lon' => lon } } }

      before do
        allow(JSON).to receive(:parse).and_return(parsed_body)
      end

      context 'with valid location data' do
        before do
          @result = subject.send(:parse_latlong, body)
        end

        it 'is expected to parse the body' do
          expect(JSON).to have_received(:parse).with(body)
        end

        it 'is expected to get the coordinates from the body' do
          expect(@result[:lat]).to eq(lat)
          expect(@result[:lon]).to eq(lon)
        end
      end

      context 'when we cannot read the coordinates data' do
        let(:lat) { '' }

        it 'it is expected to raise an error' do
          expect { subject.send(:parse_latlong, body) }.to raise_error(
            'Could not read latitude or longitude data'
          )
        end
      end
    end
  end
end
