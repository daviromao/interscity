# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.shared_examples 'make request and handle errors with method' do |method, params, request_action, request_params|
  let(:data) { double('data') }
  let(:uuid) { 'uuid' }
  let(:message) { 'Could not register Resource - Error StandardError' }

  before do
    allow(Rails).to receive_message_chain(:logger, :error)
  end

  describe method.to_s do
    context "with a successful #{method.to_s.split('_').first}" do
      let(:service_response) { 'response' }

      before do
        expect(RestClient).to receive(request_action).with(*request_params)
                                                     .and_return(service_response)
      end

      it 'is expected to return the response' do
        expect(described_class.send(method, *params)).to eq(service_response)
      end
    end

    context 'with a request error' do
      let(:error_message) { 'error message' }

      before do
        expect(RestClient).to receive(request_action).and_raise(RestClient::Exception.new(error_message))
      end

      it 'is expected to return the error message' do
        expect(described_class.send(method, *params)).to eq(error_message)
      end
    end

    context 'with other errors' do
      let(:error_message) { 'error message' }

      before do
        expect(RestClient).to receive(request_action).and_raise(StandardError.new(error_message))
      end

      it 'is expected to return nil' do
        expect(described_class.send(method, *params)).to be_nil
      end
    end
  end
end

describe Platform::ResourceManager do
  let(:data) { double('data') }
  let(:uuid) { 'uuid' }
  let(:message) { 'Could not register Resource - Error StandardError' }

  before do
    allow(Rails).to receive_message_chain(:logger, :error)
  end

  include_examples 'make request and handle errors with method', :register_resource,
                   [:data],
                   :post,
                   [SERVICES_CONFIG['services']['catalog'] + '/resources', data: :data]

  include_examples 'make request and handle errors with method', :update_resource,
                   %i[uuid data],
                   :put,
                   [SERVICES_CONFIG['services']['catalog'] + '/resources/uuid', data: :data]

  include_examples 'make request and handle errors with method', :get_resource,
                   [:uuid],
                   :get,
                   [SERVICES_CONFIG['services']['catalog'] + '/resources/uuid']
end
