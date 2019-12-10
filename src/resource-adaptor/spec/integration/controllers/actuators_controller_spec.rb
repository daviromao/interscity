# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe ActuatorsController, :integration, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#subscribe' do
    context 'existing resource' do
      before do
        cataloguer_response_body = {
          'data' => {
            'description' => 'A simple resource in São Paulo',
            'status' => 'stopped',
            'country' => 'Brazil',
            'state' => 'São Paulo',
            'postal_code' => '05508-090',
            'id' => 677,
            'lon' => -46.731386,
            'updated_at' => '2016-10-28T13:25:16.069Z',
            'uuid' => '956a8ec9-bda7-45b3-85fc-8762cee2879a',
            'city' => 'São Paulo',
            'neighborhood' => 'Butantã',
            'capabilities' => [
              'semaphore'
            ],
            'created_at' => '2016-10-28T13:25:16.069Z',
            'lat' => -23.559616
          }
        }
        cataloguer_response = double
        allow(cataloguer_response).to receive(:code).and_return(200)
        allow(cataloguer_response).to receive(:body)
          .and_return(JSON(cataloguer_response_body))
        allow(Platform::ResourceManager).to receive(:get_resource)
          .with('956a8ec9-bda7-45b3-85fc-8762cee2879a')
          .and_return(cataloguer_response)
      end

      context 'when subscribe to at least one valid capability' do
        let(:request) do
          process :subscribe, method: :post, params: {
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br',
              capabilities: ['semaphore']
            }
          }
        end

        it 'returns 201' do
          request
          expect(response).to have_http_status(:created)
        end

        it 'creates a subscription on database' do
          expect { request }.to change(Subscription, :count).by(1)
        end

        describe 'json response' do
          subject { json['subscription'] }
          before { request }

          it { is_expected.not_to be_nil }
          it { is_expected.to have_key('id') }
          it { is_expected.to have_key('uuid') }
          it { is_expected.to have_key('url') }
          it { is_expected.to have_key('capabilities') }
          it { is_expected.to have_key('active') }
        end
      end

      context 'when subscribe to invalid capabilities' do
        let(:request) do
          process :subscribe, method: :post, params: {
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br',
              capabilities: %w[invalid not_valid]
            }
          }
        end

        it 'returns 404 error' do
          request
          expect(response).to have_http_status(:not_found)
          expect(json['error']).to include('This resource does not have these capabilities')
        end

        it 'does not create a subscription on database' do
          expect { request }.to change(Subscription, :count).by(0)
        end
      end

      context 'when missing required parameters on request' do
        it 'returns 422 to empty list of capabilities' do
          process :subscribe, method: :post, params: {
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br',
              capabilities: []
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end

        it 'returns 422 for no capabilities' do
          process :subscribe, method: :post, params: {
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br'
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end

        it 'returns 422 for no uuid' do
          process :subscribe, method: :post, params: {
            subscription: {
              url: 'http://example.com.br',
              capabilities: ['semaphore']
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end

        it 'returns 422 for no url' do
          process :subscribe, method: :post, params: {
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              capabilities: ['semaphore']
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end
      end
    end

    context 'when resource is not found' do
      let(:request) do
        process :subscribe, method: :post, params: {
          subscription: {
            uuid: '123456',
            url: 'http://example.com.br',
            capabilities: ['semaphore']
          }
        }
      end

      before do
        cataloguer_response_body = {
          'error' => 'Resource with given uuid not found'
        }

        cataloguer_response = double
        allow(cataloguer_response).to receive(:code).and_return(404)
        allow(cataloguer_response).to receive(:body)
          .and_return(JSON(cataloguer_response_body))
        allow(Platform::ResourceManager).to receive(:get_resource)
          .with('123456')
          .and_return(cataloguer_response)
      end

      it 'returns 404 error' do
        request
        expect(response).to have_http_status(:not_found)
        expect(json).to have_key('error')
      end

      it 'does not create a subscription on database' do
        expect { request }.to change(Subscription, :count).by(0)
      end
    end

    context 'when Resource Catalog is unavailable' do
      let(:request) do
        process :subscribe, method: :post, params: {
          subscription: {
            uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
            url: 'http://example.com.br',
            capabilities: ['semaphore']
          }
        }
      end

      before do
        allow(Platform::ResourceManager).to receive(:get_resource).and_return(nil)
      end

      it 'returns 503 error' do
        request
        expect(response).to have_http_status(503)
        expect(json['error']).to eq('Resource Cataloguer service is unavailable')
      end

      it 'does not create a subscription on database' do
        expect { request }.to change(Subscription, :count).by(0)
      end
    end
  end

  describe '#update' do
    let(:subscription) do
      Subscription.create!(
        uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
        url: 'http://oldendpoint.com',
        capabilities: ['semaphore']
      )
    end

    context 'existing resource' do
      before do
        cataloguer_response_body = {
          'data' => {
            'description' => 'A simple resource in São Paulo',
            'status' => 'stopped',
            'country' => 'Brazil',
            'state' => 'São Paulo',
            'postal_code' => '05508-090',
            'id' => 677,
            'lon' => -46.731386,
            'updated_at' => '2016-10-28T13:25:16.069Z',
            'uuid' => '956a8ec9-bda7-45b3-85fc-8762cee2879a',
            'city' => 'São Paulo',
            'neighborhood' => 'Butantã',
            'capabilities' => %w[
              semaphore
              illuminate
            ],
            'created_at' => '2016-10-28T13:25:16.069Z',
            'lat' => -23.559616
          }
        }
        cataloguer_response = double
        allow(cataloguer_response).to receive(:code).and_return(200)
        allow(cataloguer_response).to receive(:body)
          .and_return(JSON(cataloguer_response_body))
        allow(Platform::ResourceManager).to receive(:get_resource)
          .with('956a8ec9-bda7-45b3-85fc-8762cee2879a')
          .and_return(cataloguer_response)
      end

      context 'whith valid capabilities' do
        let(:request) do
          process :update, method: :put, params: {
            id: subscription.id,
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br',
              capabilities: ['illuminate']
            }
          }
        end
        before { request }

        it 'returns success' do
          expect(response).to have_http_status(:success)
        end

        it 'updates capabilities' do
          subscription.reload
          expect(subscription.capabilities).to include('illuminate')
          expect(subscription.capabilities).not_to include('semaphore')
        end

        describe 'json response' do
          subject { json['subscription'] }

          it { is_expected.not_to be_nil }
          it { is_expected.to have_key('id') }
          it { is_expected.to have_key('uuid') }
          it { is_expected.to have_key('url') }
          it { is_expected.to have_key('capabilities') }
          it { is_expected.to have_key('active') }
        end
      end

      context 'whith invalid capabilities' do
        let(:request) do
          process :update, method: :put, params: {
            id: subscription.id,
            subscription: {
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              url: 'http://example.com.br',
              capabilities: ['invalid']
            }
          }
        end
        before { request }

        it 'returns not found' do
          expect(response).to have_http_status(:not_found)
        end

        it 'does not update capabilities' do
          subscription.reload
          expect(subscription.capabilities).to include('semaphore')
          expect(subscription.capabilities).not_to include('invalid')
        end

        it 'returns an error message' do
          expect(json).to have_key('error')
          expect(json['error']).to include('This resource does not have these capabilities:')
        end
      end

      context 'with invalid data' do
        it 'returns 422 for no uuid' do
          process :update, method: :put, params: {
            id: subscription.id,
            subscription: {
              uuid: nil,
              url: 'http://example.com.br',
              capabilities: ['semaphore']
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end

        it 'returns 422 for no url' do
          process :update, method: :put, params: {
            id: subscription.id,
            subscription: {
              url: nil,
              uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
              capabilities: ['semaphore']
            }
          }
          expect(response).to have_http_status(422)
          expect(json).to have_key('error')
        end
      end
    end

    context 'when resource is not found' do
      let(:request) do
        process :update, method: :put, params: {
          id: subscription.id,
          subscription: {
            uuid: '123456',
            url: 'http://example.com.br',
            capabilities: ['semaphore']
          }
        }
      end

      before do
        cataloguer_response_body = {
          'error' => 'Resource with given uuid not found'
        }

        cataloguer_response = double
        allow(cataloguer_response).to receive(:code).and_return(404)
        allow(cataloguer_response).to receive(:body)
          .and_return(JSON(cataloguer_response_body))
        allow(Platform::ResourceManager).to receive(:get_resource)
          .with('123456')
          .and_return(cataloguer_response)

        request
      end

      it 'returns 404 error' do
        expect(response).to have_http_status(:not_found)
        expect(json).to have_key('error')
      end

      it 'does not update uuid' do
        subscription.reload
        expect(subscription.uuid).to eq('956a8ec9-bda7-45b3-85fc-8762cee2879a')
        expect(subscription.capabilities).not_to eq('123456')
      end
    end

    context 'when Resource Catalog is unavailable' do
      let(:request) do
        process :update, method: :put, params: {
          id: subscription.id,
          subscription: {
            uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
            url: 'http://example.com.br',
            capabilities: ['semaphore']
          }
        }
      end

      before do
        allow(Platform::ResourceManager).to receive(:get_resource).and_return(nil)
      end

      it 'returns 503 error' do
        request
        expect(response).to have_http_status(503)
        expect(json['error']).to eq('Resource Cataloguer service is unavailable')
      end

      it 'does not update subscription' do
        subscription.reload
        expect(subscription.url).not_to eq('http://example.com.br')
      end
    end

    context 'when subscription is not found' do
      before do
        process :update, method: :put, params: {
          id: -1,
          subscription: {
            uuid: '123456',
            url: 'http://example.com.br',
            capabilities: ['semaphore']
          }
        }
      end

      it 'returns 404 error' do
        expect(response).to have_http_status(:not_found)
        expect(json).to have_key('error')
        expect(json['error']).to eq('Subscription not found')
      end

      it 'does not update uuid' do
        subscription.reload
        expect(subscription.uuid).to eq('956a8ec9-bda7-45b3-85fc-8762cee2879a')
        expect(subscription.capabilities).not_to eq('123456')
      end
    end
  end

  describe '#delete' do
    let(:subscription) do
      Subscription.create!(
        uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
        url: 'http://oldendpoint.com',
        capabilities: ['semaphore']
      )
    end

    context 'existing resource' do
      before do
        process :destroy, method: :delete, params: {
          id: subscription.id
        }
      end

      it 'returns no content' do
        expect(response).to have_http_status(:no_content)
      end

      it 'destroy the subscription' do
        expect { Subscription.find subscription.id }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when subscription is not found' do
      before do
        process :destroy, method: :delete, params: {
          id: -1
        }
      end

      it 'returns 404 error' do
        expect(response).to have_http_status(:not_found)
        expect(json).to have_key('error')
        expect(json['error']).to eq('Subscription not found')
      end
    end
  end

  describe '#show' do
    let(:subscription) do
      Subscription.create!(
        uuid: '956a8ec9-bda7-45b3-85fc-8762cee2879a',
        url: 'http://endpoint.com',
        capabilities: ['semaphore']
      )
    end

    context 'existing resource' do
      before do
        get :show, params: {
          id: subscription.id
        }
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct subscription' do
        expect(json['subscription']['id']).to eq(subscription.id)
        expect(json['subscription']['uuid']).to eq(subscription.uuid)
        expect(json['subscription']['url']).to eq(subscription.url)
        expect(json['subscription']['capabilities'].sort)
          .to eq(subscription.capabilities.sort)
      end
    end

    context 'when subscription is not found' do
      before do
        get :show, params: {
          id: -1
        }
      end

      it 'returns 404 error' do
        expect(response).to have_http_status(:not_found)
        expect(json).to have_key('error')
        expect(json['error']).to eq('Subscription not found')
      end
    end
  end

  describe '#index' do
    before do
      Subscription.create!(
        uuid: 'AAA',
        url: 'http://endpoint.com',
        capabilities: ['semaphore']
      )

      Subscription.create!(
        uuid: 'AAA',
        url: 'http://endpoint.com',
        capabilities: ['semaphore']
      )

      Subscription.create!(
        uuid: 'BBB',
        url: 'http://endpoint.com',
        capabilities: ['semaphore']
      )
    end

    context 'without filter' do
      before { get :index }

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all subscriptions' do
        expect(json['subscriptions'].count).to be(3)
      end
    end

    context 'with filter' do
      it 'returns only subscriptions to resource AAA' do
        get :index, params: { uuid: 'AAA' }
        expect(response).to have_http_status(:success)
        expect(json['subscriptions'].count).to be(2)
      end

      it 'returns only subscriptions to resource BBB' do
        get :index, params: { uuid: 'BBB' }
        expect(response).to have_http_status(:success)
        expect(json['subscriptions'].count).to be(1)
      end

      it 'returns an empty array of subscriptions when query is CCC' do
        get :index, params: { uuid: 'CCC' }
        expect(response).to have_http_status(:success)
        expect(json['subscriptions'].count).to be(0)
      end
    end
  end
end
