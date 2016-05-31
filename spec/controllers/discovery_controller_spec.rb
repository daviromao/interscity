require 'rails_helper'

RSpec.describe DiscoveryController, :type => :controller do

  describe '#resources' do
    it 'should return status 400 (Bad Request)' do
      get 'resources'

      expect(response.status).to eq(400)
    end

    it 'should fail when given a nil capability without value' do
      get 'resources', params: {capability: ""}

      expect(response.status).to eq(400)
    end

    it 'should fail when lon is blank' do
      get 'resources', params: {capability: "temp", lat: "212121", lon: ""}

      expect(response.status).to eq(400)
    end

    it 'should fail when lat is blank' do
      get 'resources', params: {capability: "temp", lon: "212121", lat: ""}

      expect(response.status).to eq(400)
    end

    it 'should return a set of id or ids given a capability' do
      get 'resources', params: {capability: "temp"}
      hash_response_uuids = JSON.parse(response.body)
      expected_array = ["1111", "2222"]

      expect(response.status).to eq(200)
      expect(hash_response_uuids["uuids"]).to eq (expected_array)
    end

    it 'should return data from data collector for specific params' do
      get 'resources', params: {capability: "temp", lat: "12.34", lon: "43.21"}
      expected_json = {
        "1111"=>{lat: "12.34", lon:"43.21"},
        "2222"=>{lat: "12.34", lon:"43.21"}
      }.to_json

      expect(response.status).to eq(200)
      expect(response.body).to eq (expected_json)
    end
  end
end
