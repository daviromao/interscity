# frozen_string_literal: true

require 'rails_helper'
require 'unit_helper'

describe ActuatorsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:subscriptions) { [1] }

  describe 'index' do
    before do
      allow(Subscription).to receive(:all).and_return(subscriptions)

      get :index
    end

    it 'is expected to return' do
      expect(response).to have_http_status(200)
    end

    it 'is expected to render a json with subscriptions' do
      expect(json['subscriptions']).to eq(subscriptions)
    end
  end

  describe 'show' do
    before do
      allow(Subscription).to receive(:find).and_return(subscriptions)

      get :show, params: { id: 1 }
    end

    it 'is expected to return' do
      expect(response).to have_http_status(200)
    end

    it 'is expected to render a json with the subscription' do
      expect(json['subscription']).to eq(subscriptions)
    end
  end

  describe 'subscribe' do
    context 'with an invalid subscription' do
      let(:subscription) { double('subscription', valid?: false) }
      let(:error_message) { 'some error message' }

      before do
        expect(Subscription).to receive(:new).and_return(subscription)
        expect(subscription).to receive_message_chain(:errors, :full_messages).and_return(error_message)
        post :subscribe, params: { subscription: { uuid: 1 } }
      end

      it 'is expected to have an unprocessable entity return' do
        expect(response).to have_http_status(422)
      end

      it 'is expected to render a json with an error message' do
        expect(json['error']).to eq(error_message)
      end
    end

    context 'with a valid subscription' do
      let(:subscription) { double('subscription', valid?: true) }

      before do
        expect(Subscription).to receive(:new).and_return(subscription)
        allow(subscription).to receive(:save)
        allow(subject).to receive(:valid_capabilities?).and_return(true)
        post :subscribe, params: { subscription: { uuid: 1 } }
      end

      it 'is expected to validate the capabilities' do
        expect(subject).to have_received(:valid_capabilities?)
      end

      it 'is expected to save the new subscription' do
        expect(subscription).to have_received(:save)
      end

      it 'is expected to respond with created' do
        expect(response).to have_http_status(201)
      end

      it 'is expected to render a json with the subscription' do
        expect(response.body).to include(subscription.to_json)
      end
    end
  end

  describe 'update' do
    let(:id) { 'id' }

    context 'with an invalid subscription' do
      let(:subscription) { double('subscription', valid?: false) }
      let(:error_message) { 'some error message' }

      before do
        expect(Subscription).to receive(:find).with(id).and_return(subscription)
        allow(subscription).to receive(:assign_attributes)
        expect(subscription).to receive_message_chain(:errors, :full_messages).and_return(error_message)
        put :update, params: { subscription: { uuid: 1 }, id: id }
      end

      it 'is expected to update the subscription values' do
        expect(subscription).to have_received(:assign_attributes)
      end

      it 'is expected to have an unprocessable entity return' do
        expect(response).to have_http_status(422)
      end

      it 'is expected to render a json with an error message' do
        expect(json['error']).to eq(error_message)
      end
    end

    context 'with a valid subscription' do
      let(:subscription) { double('subscription', valid?: true) }

      before do
        expect(Subscription).to receive(:find).with(id).and_return(subscription)
        allow(subscription).to receive(:assign_attributes)
        allow(subscription).to receive(:save)
        allow(subject).to receive(:valid_capabilities?).and_return(true)

        put :update, params: { subscription: { uuid: 1 }, id: id }
      end

      it 'is expected to update the subscription' do
        expect(subscription).to have_received(:assign_attributes)
      end

      it 'is expected to validate the capabilities' do
        expect(subject).to have_received(:valid_capabilities?)
      end

      it 'is expected to save the updated subscription' do
        expect(subscription).to have_received(:save)
      end

      it 'is expected to respond with success' do
        expect(response).to have_http_status(200)
      end

      it 'is expected to render a json with the subscription' do
        expect(response.body).to include(subscription.to_json)
      end
    end
  end

  describe 'destroy' do
    let(:id) { 'id' }
    let(:subscription) { double('subscription', destroy: true) }

    before do
      expect(Subscription).to receive(:find).with(id).and_return(subscription)
      delete :destroy, params: { id: id }
    end

    it 'is expected to delete the subscription' do
      expect(subscription).to have_received(:destroy)
    end

    it 'is expected to render no content' do
      expect(response.body).to eq(' ')
      expect(response).to have_http_status(204)
    end
  end

  describe 'private methods' do
    describe 'set_subscription' do
      let(:subscription) { double('subscription') }

      context 'when successfully finding the subscription' do
        it 'is expected to set the controller subscription' do
          expect(Subscription).to receive(:find).and_return(subscription)
          subject.send(:set_subscription)

          expect(subject.instance_variable_get('@subscription')).to eq(subscription)
        end
      end

      context 'when the subscription is not found' do
        let(:error) { { error: 'Subscription not found' } }

        before do
          expect(Subscription).to receive(:find) { raise ActiveRecord::RecordNotFound }
          allow(subject).to receive(:render)

          subject.send(:set_subscription)
        end

        it 'is expected to render an error message' do
          expect(subject).to have_received(:render).with(json: error, status: :not_found)
        end
      end
    end

    describe 'valid_capabilities?' do
      let(:subscription) { double('subscription', capabilities: []) }
      let(:available_capabilities) { %w[temperature pressure] }

      context 'when there is an error retrieving available capabilities' do
        it 'is expected to return false' do
          expect(subject).to receive(:fetch_resource_capabilities).and_return(false)

          expect(subject.send(:valid_capabilities?, subscription)).to be false
        end
      end

      context 'when there are no valid capabilities' do
        before do
          expect(subject).to receive(:fetch_resource_capabilities)
            .and_return(available_capabilities)
          allow(subject).to receive(:render)

          @result = subject.send(:valid_capabilities?, subscription)
        end

        it 'is expected to render an error json' do
          expect(subject).to have_received(:render).with(
            json: {
              error: 'This resource does not have these capabilities: []'
            },
            status: :not_found
          )
        end

        it 'is expected to return false' do
          expect(@result).to be false
        end
      end

      context 'when there are valid capabilities' do
        let(:subscription) { double('subscription', capabilities: ['temperature']) }

        it 'is expected to return true' do
          expect(subject).to receive(:fetch_resource_capabilities)
            .and_return(available_capabilities)

          expect(subject.send(:valid_capabilities?, subscription)).to be true
        end
      end
    end

    describe 'fetch_resource_capabilities' do
      let(:subscription) { double('subscription', uuid: 'uuid') }

      context 'when the resource cataloguer service is unavailable' do
        before do
          allow(subject).to receive(:render)
          expect(Platform::ResourceManager).to receive(:get_resource)
            .with(subscription.uuid)

          @result = subject.send(:fetch_resource_capabilities, subscription)
        end

        it 'is expected to render an error json' do
          expect(subject).to have_received(:render).with(
            json: { error: 'Resource Cataloguer service is unavailable' },
            status: :service_unavailable
          )
        end

        it 'is expected to return false' do
          expect(@result).to be false
        end
      end

      context 'when there is an error getting the resource capabilities' do
        let(:body) { '{"error":"some error"}' }
        let(:service_response) { double('response', code: 500, body: body) }

        before do
          allow(subject).to receive(:render)
          expect(Platform::ResourceManager).to receive(:get_resource)
            .with(subscription.uuid).and_return(service_response)

          @result = subject.send(:fetch_resource_capabilities, subscription)
        end

        it 'is expected to render an error json' do
          expect(subject).to have_received(:render).with(
            json: service_response.body,
            status: service_response.code
          )
        end

        it 'is expected to return false' do
          expect(@result).to be false
        end
      end

      context 'when successfully getting the resource' do
        let(:capability) { 'pressure' }
        let(:body) { "{\"data\":{\"capabilities\":\"#{capability}\"}}" }
        let(:service_response) { double('response', code: 200, body: body) }

        before do
          expect(Platform::ResourceManager).to receive(:get_resource)
            .with(subscription.uuid).and_return(service_response)

          @result = subject.send(:fetch_resource_capabilities, subscription)
        end

        it 'is expected to return the resource capabilities' do
          expect(@result).to eq(capability)
        end
      end
    end
  end
end
