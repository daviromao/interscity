# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe '/adaptor' do
  describe '/resources' do
    let(:name) { 'temperature' }
    let(:description) { 'Environment temperature' }
    let(:type) { 'sensor' }
    let(:status) { 'active' }
    let(:lat) { -23.559616 }
    let(:lon) { -46.731386 }

    describe 'POST /' do
      before do
        connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
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

      after do
        connection.delete("catalog/capabilities/#{name}")
      end
    end

    describe '/{uuid}' do
      describe 'PUT /' do
        let(:new_description) { "#{description} new description" }

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

          uuid = response_json(create_response)['data']['uuid']

          @response = connection.put(
            "adaptor/resources/#{uuid}",
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

        after do
          connection.delete("catalog/capabilities/#{name}")
        end
      end
    end
  end
end
