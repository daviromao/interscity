# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe 'Resource not found bug' do
  cap_1_name = 'Media 8h_O3'
  cap_2_name = 'Media horaria_O3'
  cap_3_name = 'Indice_O3'

  let(:cap_description) { 'O3 measurement (µg/m³)' }
  let(:cap_type) { 'sensor' }

  before do
    @responses = []
    [cap_1_name, cap_2_name, cap_3_name].each do |name|
      connection.delete("catalog/capabilities/#{name.gsub(' ', '%20')}")

      @responses << connection.post(
        'catalog/capabilities',
        name: name,
        description: cap_description,
        capability_type: cap_type
      )
    end

    resource_response = connection.post(
      'adaptor/resources',
      data: {
        description: 'CETESB-Cid.Universitária-USP-Ipen-1',
        capabilities: [cap_1_name, cap_2_name, cap_3_name],
        status: 'active',
        lat: -23.5521216,
        lon: -46.932386
      }
    )
    @responses << resource_response
    @resource_uuid = response_json(resource_response)['data']['uuid']

    @responses << connection.post(
      "adaptor/resources/#{@resource_uuid}/data",
      data: {
        '::not created capacity::' => [{ value: 50, timestamp: '20/01/2019T10:27:29' }]
      }
    )

    (0..9).each do |i|
      @responses << connection.post(
        "adaptor/resources/#{@resource_uuid}/data",
        data: {
          cap_1_name => [{ value: 50, timestamp: "20/01/2019T10:27:3#{i}" }],
          cap_2_name => [{ value: '15', timestamp: "20/01/2019T10:27:3#{i}" }],
          cap_3_name => [{ value: '30', timestamp: "20/01/2019T10:27:3#{i}" }]
        }
      )
    end
  end

  it 'is expected to have all successful responses' do
    @responses.each do |response|
      expect(response.status).to be >= 200
      expect(response.status).to be <= 299
    end
  end

  it "is expected to list the resource's historical data" do
    response = connection.get("/collector/resources/#{@resource_uuid}/data")
    expect(response.status).to eq(200)
  end

  after :all do
    [cap_1_name, cap_2_name, cap_3_name].each do |name|
      connection.delete("catalog/capabilities/#{name.gsub(' ', '%20')}")
    end
  end
end
