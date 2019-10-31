# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

uuid = ''

RSpec.shared_examples 'resource data' do |path|
  name = 'temperature'
  description = 'Environment temperature'
  type = 'sensor'
  status = 'active'
  lat = -23.559616
  lon = -46.731386
  data = [
    { temperature: 10, timestamp: '2017-06-14T17:52:25.428Z' },
    { temperature: 10, timestamp: '2017-06-15T17:52:25.428Z' }
  ]

  before :all do
    connection.post(
      'catalog/capabilities',
      name: name,
      description: description,
      capability_type: type
    )

    response = connection.post(
      'adaptor/resources',
      data: {
        description: description,
        capabilities: [name],
        status: status,
        lat: lat,
        lon: lon
      }
    )

    @uuid = response_json(response)['data']['uuid']
    uuid = @uuid

    sleep 0.5

    connection.post(
      "adaptor/resources/#{@uuid}/data",
      data: {
        environment_monitoring: data
      }
    )

    connection.headers = { 'Content-Type' => 'application/json' }

    sleep 0.5
  end

  after :all do
    connection.delete("catalog/capabilities/#{name}")
  end

  before do
    connection.headers = { 'Content-Type' => 'application/json' }
    @response = connection.post(path)
  end

  it 'is expected to respond with success' do
    expect(@response.status).to be(200)
  end

  it 'is expected to return a list of resources' do
    json = response_json(@response)

    expect(json['resources']).to be_an_instance_of(Array)
  end

  it 'is expected to have some capability data' do
    resource_data = response_json(@response)['resources'].first
    capability_data = resource_data.dig(
      'capabilities',
      'environment_monitoring'
    ).first

    expect(capability_data[name]).to eq(data.first[name.to_sym])
  end
end

RSpec.describe '/collector' do
  describe '/resources' do
    describe '/data' do
      describe 'POST /' do
        include_examples 'resource data', 'collector/resources/data'
      end

      describe '/last' do
        describe 'POST /' do
          include_examples 'resource data', 'collector/resources/data/last'
        end
      end
    end

    describe '/{uuid}' do
      describe '/data' do
        describe 'POST /' do
          include_examples 'resource data', "collector/resources/#{uuid}/data"
        end

        describe '/last' do
          describe 'POST /' do
            include_examples(
              'resource data',
              "collector/resources/#{uuid}/data/last"
            )
          end
        end
      end
    end
  end
end
