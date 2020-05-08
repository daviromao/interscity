# frozen_string_literal: true

require 'rails_helper'
require 'workers/worker_helper'

RSpec.describe ResourceUpdater do
  let(:channel) { double('channel') }
  let(:queue) { double('queue') }

  before do
    allow(Rails).to receive_message_chain(:configuration, :worker_conn, :create_channel).and_return(channel)
    allow(channel).to receive(:prefetch)
    allow(channel).to receive(:topic)
    allow(channel).to receive(:queue).and_return(queue)
  end

  include_examples 'resource_init with queue parameters', described_class::QUEUE

  describe 'perform' do
    let(:body) { double('body') }
    let(:json) { double('json') }

    before do
      allow(queue).to receive(:bind)
      allow(queue).to receive(:subscribe) { |&block| block.call(nil, nil, body) }
    end

    context 'with an error when parsing the json' do
      before do
        expect(JSON).to receive(:parse).with(body) { raise StandardError }

        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:error)

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to log an error' do
        expect(WORKERS_LOGGER).to have_received(:error).with(
          'ResourceUpdater::ResourceNotUpdated - StandardError'
        )
      end
    end

    context 'with succesfully parsing the json' do
      before do
        allow(JSON).to receive(:parse).and_return(json)
        allow(json).to receive(:slice)
        allow(subject).to receive(:update_resource)

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to parse the json' do
        expect(JSON).to have_received(:parse).with(body)
      end
    end
  end

  include_examples 'resource_cancel'

  describe 'private methods' do
    describe 'update_resource' do
      let(:resource) { double('resource') }
      let(:resource_attributes) { 'attributes' }

      before do
        allow(PlatformResource).to receive(:find_by).and_return(resource)
        allow(resource).to receive(:update!)

        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:info)

        subject.send(:update_resource, resource_attributes, 'uuid' => 0)
      end

      it 'is expected to find the resource' do
        expect(PlatformResource).to have_received(:find_by).with(uuid: 0)
      end

      it 'is expected to update the resource' do
        expect(resource).to have_received(:update!).with(resource_attributes)
      end

      it 'is expected to log the update' do
        expect(WORKERS_LOGGER).to(
          have_received(:info)
            .with("ResourceUpdater::ResourceUpdated -  #{resource_attributes}")
        )
      end
    end
  end
end
