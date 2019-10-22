# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.shared_examples 'capability search' do |path, hash_key|
  before do
    @response = connection.get("catalog/#{path}")
  end

  it 'is expected to respond with success' do
    expect(@response.status).to be(200)
  end

  context 'JSON format' do
    before do
      @json = response_json(@response)
    end

    it 'is expected to have the "capabilities" key' do
      expect(@json.key?(hash_key)).to be true
    end

    it "is expected to have an Array as value to the \"#{hash_key}\" key" do
      expect(@json[hash_key]).to be_an(Array)
    end
  end
end

RSpec.describe '/catalog' do
  let(:name) { 'temperature' }
  let(:description) { 'Environment temperature' }
  let(:type) { 'sensor' }
  let(:status) { 'active' }
  let(:lat) { -23.559616 }
  let(:lon) { -46.731386 }

  describe '/resources' do
    describe 'GET /' do
      it 'is expected to respond with success' do
        response = connection.get('catalog/resources')

        expect(response.status).to be(200)
      end
    end

    describe 'POST /' do
      before do
        connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
        @response = connection.post(
          'catalog/resources',
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

    describe 'GET /sensors' do
      include_examples 'capability search', 'resources/sensors', 'resources'
    end

    describe 'GET /actuators' do
      include_examples 'capability search', 'resources/actuators', 'resources'
    end

    describe 'GET /search' do
      include_examples 'capability search', 'resources/search', 'resources'
    end

    describe 'PUT /{uuid}' do
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
          "catalog/resources/#{uuid}",
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

    describe 'GET /{uuid}' do
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

        @response = connection.get("catalog/resources/#{uuid}")
      end

      it 'is expected to respond with success' do
        expect(@response.status).to be(200)
      end

      after do
        connection.delete("catalog/capabilities/#{name}")
      end
    end
  end

  describe '/capabilities' do
    describe 'GET /' do
      include_examples 'capability search', 'capabilities', 'capabilities'
    end

    describe 'POST /' do
      before do
        @response = connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
      end

      it 'is expected to respond with success' do
        expect(@response.status).to be(201) # 201 - Created
      end

      after do
        connection.delete("catalog/capabilities/#{name}")
      end
    end

    describe 'GET /{name}' do
      before do
        connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
        @response = connection.get("catalog/capabilities/#{name}")
      end

      it 'is expected to respond with success' do
        expect(@response.status).to eq(200)
      end

      after do
        connection.delete("catalog/capabilities/#{name}")
      end
    end

    describe 'PUT /{name}' do
      let(:new_description) { "#{description} new description" }

      before do
        connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
        @response = connection.put(
          "catalog/capabilities/#{name}",
          data: { description: new_description }
        )
      end

      it 'is expected to respond with success' do
        expect(@response.status).to eq(202) # 202 - Accepted
      end

      xit 'is expected to update the resource' do # See: https://gitlab.com/interscity/interscity-platform/interscity-platform/issues/35
        json = response_json(@response)

        expect(json['description']).to eq(new_description)
      end

      after do
        connection.delete("catalog/capabilities/#{name}")
      end
    end

    describe 'DELETE /{name}' do
      before do
        connection.post(
          'catalog/capabilities',
          name: name,
          description: description,
          capability_type: type
        )
        @response = connection.delete("catalog/capabilities/#{name}")
      end

      it 'is expected to respond with success' do
        expect(@response.status).to eq(204) # 204 - No Content
      end
    end
  end
end
