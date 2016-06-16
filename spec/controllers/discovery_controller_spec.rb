require 'rails_helper'

describe DiscoveryController, :type => :controller do

  describe '#resources' do

    before(:all) do
      @controller = DiscoveryController.new

    end
    it 'when no params found, should fail - return status 400 (Bad Request)' do
        get 'resources'
        expect(response.status).to eq(400)
    end

    it 'when capability has no value found, should fail' do
      get 'resources', params: {capability: ""}
      expect(response.status).to eq(400)
    end

    it 'when lat has no value found, should fail' do
      get 'resources', params: {capability: "temp", lon: "212121", lat: ""}

      expect(response.status).to eq(400)
    end

    it 'when lon has no value found, should fail' do
      get 'resources', params: {capability: "temp", lat: "212121", lon: ""}

      expect(response.status).to eq(400)
    end

    it 'when inform a capability, should return OK and a set of id or ids given a capability' do
      get 'resources', params: {capability: "temp"}
      hash_response_uuids = JSON.parse(response.body)
      expected_array = ["1111", "2222"]

      expect(response.status).to eq(200)
      expect(hash_response_uuids["uuids"]).to eq (expected_array)
    end

    it 'when inform a cap/lat/lon, should return OK and data from data collector for specific params' do
      get 'resources', params: {capability: "temp", lat: "12.34", lon: "43.21"}
      hash_response_uuids = JSON.parse(response.body)
      expected_json = ["1111","2222"]

      expect(response.status).to eq(200)
      expect(hash_response_uuids["uuids"]).to eq (expected_json)
    end
    
    it 'when inform a cap/rad without coordinates, should fail' do
      get 'resources', params: {capability: "temp", radius:"100"}
      
      expect(response.status).to eq(400)
    end

    it 'when inform a cap/lat/lon/rad, should return OK and resources based on lat lon within a radius' do
      get 'resources', params: {capability: "temp", lat: "12.34", lon: "43.21", radius:"100"}
      hash_response_uuids = JSON.parse(response.body)
      expected_json = ["4444","3333"]

      expect(response.status).to eq(200)
      expect(hash_response_uuids["uuids"]).to eq (expected_json)
    end

    it 'when no found data in catalog that match params, should return 404' do
      get 'resources', params: {capability: "temp", lat: "12.34", lon: "43.21", radius:80}
      hash_response_uuids = JSON.parse(response.body)
      expected_json = nil

      expect(response.status).to eq(404)
      expect(hash_response_uuids["uuids"]).to eq (expected_json)
    end

    it 'when inform a cap/start/end_range, should return OK and resources based on data range' do
      get 'resources', params: {capability: "temp", start_range:20, end_range:30}
      hash_response_uuids = JSON.parse(response.body)
      expected_json = ["1111","2222"]  # rever!!!!

      expect(response.status).to eq(200)
      expect(hash_response_uuids["uuids"]).to eq (expected_json)
    end

  end
end
