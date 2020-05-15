# frozen_string_literal: true

require 'rails_helper'
require 'rest-client'

RSpec.describe WebHookCaller do
  describe 'perform' do
    let(:id) { 'id' }
    let(:url) { 'http://www.example.com' }
    let(:body) { '[]' }
    let(:command) do
      {
        'url' => url,
        '_id' => { '$oid' => '1' }
      }
    end

    before do
      allow(JSON).to receive_message_chain(:parse, :slice).and_return(command)

      WORKERS_LOGGER = double('workers_logger')
      allow(WORKERS_LOGGER).to receive(:error)
    end

    context 'with no errors' do
      before do
        allow(subject).to receive(:call_webhook)

        subject.perform(id, url, body)
      end

      it 'is expected to parse the body' do
        expect(JSON).to have_received(:parse).with(body)
      end

      it 'is expected to call the webhook' do
        expect(subject).to have_received(:call_webhook).with(
          command, id, url
        )
      end
    end

    context 'with a rest client error' do
      before do
        expect(subject).to receive(:call_webhook) do
          raise RestClient::ExceptionWithResponse
        end

        allow(DataManager).to receive_message_chain(
          :instance, :publish_actuation_command_status
        )

        subject.perform(id, url, body)
      end

      it 'is expected to log the error' do
        expect(WORKERS_LOGGER).to have_received(:error).with(
          "WebHookCaller::CommandNotSent - notification_id: #{id}, url: #{url}, error: RestClient::ExceptionWithResponse"
        )
      end

      it 'is expected to publish the command as rejected' do
        expect(DataManager.instance).to have_received(:publish_actuation_command_status).with(
          command['uuid'],
          command['capability'],
          command['_id']['$oid'],
          'rejected'
        )
      end
    end

    context 'with another error' do
      before do
        expect(subject).to receive(:call_webhook) { raise StandardError }
      end

      it 'is expected to log the error and raise it again' do
        expect { subject.perform(id, url, body) }.to raise_error

        expect(WORKERS_LOGGER).to have_received(:error).with(
          "WebHookCaller::CommandNotSent - notification_id: #{id}, url: #{url}, error: StandardError"
        )
      end
    end
  end
end
