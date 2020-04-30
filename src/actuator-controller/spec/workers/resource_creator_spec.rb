# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceCreator do
  let(:channel) { double('channel') }
  let(:queue) { double('queue') }

  before do
    allow(Rails).to receive_message_chain(:configuration, :worker_conn, :create_channel).and_return(channel)
    allow(channel).to receive(:prefetch)
    allow(channel).to receive(:topic)
    allow(channel).to receive(:queue).and_return(queue)
  end

  describe 'initialize' do
    before { subject }

    it 'is expected to create a channel' do
      expect(Rails.configuration.worker_conn).to have_received(:create_channel)
    end

    it 'is expected to prefetch the channel' do
      expect(channel).to have_received(:prefetch).with(2)
    end

    it 'is expected to get the channel topic' do
      expect(channel).to have_received(:topic).with(described_class::TOPIC)
    end

    it 'is expected to get the channel queue' do
      expect(channel).to have_received(:queue).with(
        described_class::QUEUE,
        durable: true,
        auto_delete: false
      )
    end
  end

  describe 'perform' do
    let(:body) { double('body') }
    let(:json) { double('json') }

    before do
      allow(queue).to receive(:bind)
      allow(queue).to receive(:subscribe) { |&block| block.call(nil, nil, body) }

      WORKERS_LOGGER = double('workers_logger')
      allow(WORKERS_LOGGER).to receive(:info)
      allow(WORKERS_LOGGER).to receive(:error)
    end

    context 'with an error when parsing the json' do
      before do
        expect(JSON).to receive(:parse).with(body) { raise StandardError }

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to log an error' do
        expect(WORKERS_LOGGER).to have_received(:error).with(
          'ResourceCreator::ResourceNotCreated - StandardError'
        )
      end
    end

    context 'with succesfully parsing the json' do
      let(:resource_attributes) { 'attributes' }
      before do
        allow(JSON).to receive(:parse).and_return(json)
        allow(json).to receive(:slice).and_return(resource_attributes)
        allow(PlatformResource).to receive(:create!)

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to parse the json' do
        expect(JSON).to have_received(:parse).with(body)
      end

      it 'is expected to create the resource' do
        expect(PlatformResource).to have_received(:create!).with(resource_attributes)
      end

      it 'is expected to log the update' do
        expect(WORKERS_LOGGER).to have_received(:info).with(
          "ResourceCreator::ResourceCreated - #{resource_attributes}"
        )
      end
    end
  end

  describe 'cancel' do
    let(:consumer) { double('consumer') }
    let(:consumers) { [consumer] }

    before do
      allow(consumer).to receive(:cancel)
      allow(channel).to receive(:close)

      subject.instance_variable_set('@consumers', consumers)
      subject.cancel
    end

    it 'is expected to cancel the consumers' do
      expect(consumer).to have_received(:cancel)
    end

    it 'is expected to close the channel' do
      expect(channel).to have_received(:close)
    end
  end
end
