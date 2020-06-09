# frozen_string_literal: true

require 'rails_helper'
require 'rest-client'

RSpec.describe WebHookCaller do
  let(:command) do
    {
      'url' => url,
      '_id' => { '$oid' => '1' }
    }
  end
  let(:id) { 'id' }
  let(:url) { 'http://www.example.com' }
  let(:body) { '[]' }

  describe 'perform' do
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
        error = 'RestClient::ExceptionWithResponse'
        expect(WORKERS_LOGGER).to have_received(:error).with(
          "WebHookCaller::CommandNotSent - notification_id: #{id}, url: #{url}, error: #{error}"
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

  describe 'private methods' do
    describe 'call_webhook' do
      before do
        allow(RestClient).to receive(:post)
        allow(DataManager).to receive_message_chain(:instance, :publish_actuation_command_status)

        WORKERS_LOGGER = double('workers_logger')
        allow(WORKERS_LOGGER).to receive(:info)

        subject.send(:call_webhook, command, id, url)
      end

      it 'is expected to send the command to actuator_command' do
        expect(RestClient).to have_received(:post).with(
          url,
          { action: 'actuator_command', command: command }.to_json,
          content_type: :json, accept: :json
        )
      end

      it 'is expected to log the sent command' do
        expect(WORKERS_LOGGER).to have_received(:info).with(
          "WebHookCaller::CommandSent - notification_id: #{id}, url: #{url}"
        )
      end
    end
  end
end
