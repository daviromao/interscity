# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe '/actuator' do
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

  describe '/actuator' do
    describe '/commands' do
      describe 'GET /' do
        before do
          @response = connection.get('actuator/commands')
        end

        it 'is expected to respond with success' do
          expect(@response.status).to be(200)
        end

        it 'is expected to return a list of commands' do
          json = response_json(@response)

          expect(json['commands']).to be_an_instance_of(Array)
        end
      end

      describe 'POST /' do
        before do
          @response = connection.post(
            'actuator/commands',
            data: [
              {
                uuid: @resource_uuid,
                capabilities: [name]
              }
            ]
          )
        end

        it 'is expected to respond with success' do
          expect(@response.status).to be(200)
        end

        it 'is expected to have failure and success fields' do
          json = response_json(@response)

          expect(json).to have_key('failure')
          expect(json).to have_key('success')
        end
      end
    end
  end
end
