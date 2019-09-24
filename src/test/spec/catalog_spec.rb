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

RSpec.describe 'catalog' do
  describe 'GET resources' do
    it 'is expected to respond with success' do
      response = connection.get('catalog/resources')

      expect(response.status).to be(200)
    end
  end

  describe 'GET capabilities' do
    include_examples 'capability search', 'capabilities', 'capabilities'
  end

  describe 'POST capabilities' do
    let(:name) { 'temperature' }
    let(:description) { 'Environment temperature' }
    let(:type) { 'sensor' }

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

  describe 'DELETE capabilities' do
    let(:name) { 'temperature' }
    let(:description) { 'Environment temperature' }
    let(:type) { 'sensor' }

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

  describe 'GET resources/sensors' do
    include_examples 'capability search', 'resources/sensors', 'resources'
  end
end
