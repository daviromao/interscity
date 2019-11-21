# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe '/adaptor' do
  let(:name) { 'temperature' }
  let(:description) { 'Environment temperature' }
  let(:type) { 'sensor' }
  let(:status) { 'active' }
  let(:lat) { -23.559616 }
  let(:lon) { -46.731386 }

  before do
    connection.post(
      'catalog/capabilities',
      name: name,
      description: description,
      capability_type: type
    )

    create_response = connection.post(
      'catalog/resources',
      data: {
        description: description,
        capabilities: [name],
        status: status,
        lat: lat,
        lon: lon
      }
    )

    @resource_uuid = response_json(create_response)['data']['uuid']
  end

  after do
    connection.delete("catalog/capabilities/#{name}")
  end

  describe '/resources' do
    describe 'POST /' do
      before do
        @response = connection.post(
          'adaptor/resources',
          data: {
            description: description,
            capabilities: [name],
            status: status,
            lat: lat,
            lon: lon
          }
        )
      end

      it 'is expected to respond with success' do
        expect(@response.status).to be(201) # 201 - Created
      end
    end

    describe '/{uuid}' do
      describe 'PUT /' do
        let(:new_description) { "#{description} new description" }

        before do
          @response = connection.put(
            "adaptor/resources/#{@resource_uuid}",
            data: { description: new_description }
          )
        end

        it 'is expected to respond with success' do
          expect(@response.status).to be(200)
        end

        it 'is expected to update the resource' do
          json = response_json(@response)

          expect(json['data']['description']).to eq(new_description)
        end
      end

      describe '/data' do
        describe 'POST /' do
          before do
            @response = connection.post(
              "/adaptor/resources/#{@resource_uuid}/data",
              data: {
                "environment_monitoring": [
                  {
                    "temperature": 10
                  }
                ]
              }
            )
          end

          it 'is expected to respond with success' do
            expect(@response.status).to be(201) # 201 - Created
          end
        end

        describe 'POST /{capability}' do
          before do
            @response = connection.post(
              "/adaptor/resources/#{@resource_uuid}/data/#{name}",
              data: [
                { "temperature": 10 }
              ]
            )
          end

          it 'is expected to respond with success' do
            expect(@response.status).to be(201) # 201 - Created
          end
        end
      end
    end
  end

  describe '/subscriptions' do
    describe 'POST /' do
      before do
        @response = connection.post(
          '/adaptor/subscriptions',
          subscription: {
            uuid: @resource_uuid,
            capabilities: [name],
            url: 'http://127.0.0.1'
          }
        )
      end

      it 'is expected to respond with success' do
        expect(@response.status).to be(201) # 201 - Created
      end
    end

    describe 'GET /' do
      before do
        @response = connection.get('/adaptor/subscriptions')
      end

      it 'is expected to respond with success' do
        expect(@response.status).to be(200)
      end

      it 'is expected to have subscriptions data' do
        json = response_json(@response)

        expect(json['subscriptions'].empty?).to be(false)
      end
    end

    describe '/{id}' do
      before do
        response = connection.post(
          '/adaptor/subscriptions',
          subscription: {
            uuid: @resource_uuid,
            capabilities: [name],
            url: 'http://127.0.0.1'
          }
        )

        @subscription_id = response_json(response)['subscription']['id']
      end

      describe 'PUT /' do
        let(:new_subscription) { { url: 'new endpoint' } }

        before do
          @response = connection.put(
            "/adaptor/subscriptions/#{@subscription_id}",
            subscription: new_subscription
          )
        end

        it 'is expected to respond with success' do
          expect(@response.status).to eq(200)
        end

        it 'is expected to update the subscription' do
          json = response_json(@response)

          expect(json['subscription']['url']).to eq(new_subscription[:url])
        end
      end

      describe 'GET /' do
        before do
          @response = connection.get(
            "/adaptor/subscriptions/#{@subscription_id}"
          )
        end

        it 'is expected to respond with success' do
          expect(@response.status).to eq(200)
        end

        it 'is expected to have subscription fields' do
          json = response_json(@response)

          %w[id active uuid capabilities url created_at updated_at].each do |f|
            expect(json['subscription'][f]).not_to be_nil
          end
        end
      end
    end
  end
end
