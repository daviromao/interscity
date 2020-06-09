# frozen_string_literal: true

require 'rails_helper'
require 'workers/worker_helper'

RSpec.describe ActuatorCommandNotifier do
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
    let(:uuid) { 'uuid' }
    let(:capability) { 'capability' }
    let(:json) { { 'uuid' => uuid, 'capability' => capability } }

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
          'ActuatorCommandNotifier::CommandNotProcessed - StandardError'
        )
      end
    end

    context 'with succesfully parsing the json' do
      before do
        allow(JSON).to receive(:parse).and_return(json)
        allow(subject).to receive(:schedule_webhooks)

        subject.perform
      end

      it 'is expected to subscribe to a queue' do
        expect(queue).to have_received(:subscribe).with(block: false)
      end

      it 'is expected to parse the json' do
        expect(JSON).to have_received(:parse).with(body)
      end

      it 'is expected to schedule the webhook' do
        expect(subject).to have_received(:schedule_webhooks).with(
          uuid, json, capability, body
        )
      end
    end
  end

  include_examples 'resource_cancel'

  describe 'private methods' do
    describe 'schedule_webhooks' do
      let(:uuid) { 'uuid' }
      let(:json) { { 'uuid' => uuid, 'capability' => capability } }
      let(:capability) { 'temperature' }
      let(:body) { double('body') }
      let(:subscription) do
        double 'subscription',
               capabilities: [capability],
               id: 1,
               url: 'kjn'
      end

      before do
        allow(Subscription).to receive(:where).and_return([subscription])
        allow(WebHookCaller).to receive(:perform_async)

        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:info)

        subject.send(:schedule_webhooks, uuid, json, capability, body)
      end

      it 'is expected to search for the active subscription' do
        expect(Subscription).to have_received(:where).with(uuid: uuid, active: true)
      end

      it 'is expected to schedule the webhook' do
        expect(WebHookCaller).to have_received(:perform_async).with(
          subscription.id,
          subscription.url,
          body
        )
      end

      it 'is expected to log the received command' do
        expect(WORKERS_LOGGER).to have_received(:info).with(
          "ActuatorCommandNotifier::CommandReceived - #{json}"
        )
      end
    end
  end
end
