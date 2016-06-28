require 'rails_helper'

describe DiscoveryController, type: 'controller' do
  describe '#resources' do
    before do
      @controller = DiscoveryController.new
      allow(@controller).to receive(:call_to_resource_catalog).and_return({})
      allow(@controller).to receive(:call_to_data_collector).and_return({})
    end

    it 'when no params found, should fail - return status 400 (Bad Request)' do
      get 'resources'
      expect(response.status).to eq(400)
    end

    it 'when capability has no value found, should fail' do
      get 'resources', params: { capability: '' }
      expect(response.status).to eq(400)
    end

    it 'when lat has no value found, should fail' do
      get 'resources', params: { capability: 'temp', lon: '212121', lat: '' }

      expect(response.status).to eq(400)
    end

    it 'when lon has no value found, should fail' do
      get 'resources', params: { capability: 'temp', lat: '212121', lon: '' }

      expect(response.status).to eq(400)
    end

    it 'when inform a capability, should return OK and a set of id or ids given a capability' do
      catalog_response = { 'resources' => [{ 'uuid' => '1', 'lat' => '10', 'lon' => '10' },
                                           { 'uuid' => '2', 'lat' => '20', 'lon' => '20' },
                                           { 'uuid' => '3', 'lat' => '30', 'lon' => '30' }] }

      allow(@controller).to receive(:call_to_resource_catalog).and_return(catalog_response)

      get 'resources', params: { capability: 'temp' }
      hash_response_uuids = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(hash_response_uuids).to eq(catalog_response)
    end

    it 'when inform a cap/lat/lon, should return OK and data from data collector for specific params' do
      catalog_response = { 'resources' => [{ 'uuid' => '2', 'lat' => '20', 'lon' => '20' },
                                           { 'uuid' => '3', 'lat' => '30', 'lon' => '30' }] }

      allow(@controller).to receive(:call_to_resource_catalog).and_return(catalog_response)

      get 'resources', params: { capability: 'temp', lat: '12.34', lon: '43.21' }
      hash_response_uuids = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(hash_response_uuids).to eq(catalog_response)
    end

    it 'when inform a cap/rad without coordinates, should fail' do
      get 'resources', params: { capability: 'temp', radius: '100' }

      expect(response.status).to eq(400)
    end

    it 'when inform a cap/lat/lon/rad, should return OK and resources based on lat lon within a radius' do
      catalog_response = { 'resources' => [{ 'uuid' => '4', 'lat' => '40', 'lon' => '40' },
                                           { 'uuid' => '5', 'lat' => '40', 'lon' => '40' },
                                           { 'uuid' => '7', 'lat' => '40', 'lon' => '40' }] }

      allow(@controller).to receive(:call_to_resource_catalog).and_return(catalog_response)

      get 'resources', params: { capability: 'temp', lat: '12.34', lon: '43.21', radius: '100' }
      hash_response_uuids = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(hash_response_uuids).to eq(catalog_response)
    end

    it 'when no found data in catalog that match params, should return 404' do
      get 'resources', params: { capability: 'temp', lat: '12.34', lon: '43.21', radius: 80 }
      hash_response_uuids = JSON.parse(response.body)
      expected_json = { 'code' => 'NotFound', 'message' => 'No resources have been found' }

      expect(response.status).to eq(404)
      expect(hash_response_uuids).to eq(expected_json)
    end

    context 'when inform a cap/min/max range' do
      it 'properly returns all resources found by both catalog and collector' do
        catalog_response = { 'resources' => [{ 'uuid' => '7', 'lat' => '40', 'lon' => '40' }] }
        collector_response = {  'resources' =>
                                [{ 'uuid' => '7', 'capabilities' =>
                                    { 'temp' => [{ 'value' => '28.31', 'date' => '2016-06-21T23:27:35.000Z' }] } }] }

        allow(@controller).to receive(:call_to_resource_catalog).and_return(catalog_response)
        allow(@controller).to receive(:call_to_data_collector).and_return(collector_response)

        get 'resources', params: { capability: 'temp',
                                   lat: '12.34', lon: '43.21',
                                   radius: '100',
                                   min_cap_value: 20, max_cap_value: 30 }
        hash_response_uuids = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(hash_response_uuids).to eq('resources' => ['uuid' => '7', 'lat' => '40', 'lon' => '40'])
      end

      it 'properly returns only resources found by catalog that match with collector results' do
        catalog_response = {  'resources' =>
                              [{ 'uuid' => '4', 'lat' => '40', 'lon' => '40' },
                               { 'uuid' => '5', 'lat' => '40', 'lon' => '40' },
                               { 'uuid' => '7', 'lat' => '40', 'lon' => '40' }] }
        collector_response = { 'resources' =>
                                [{ 'uuid' => '7',
                                   'capabilities' => { 'temp' => [{ 'value' => '28.31',
                                                                    'date' => '2016-06-21T23:27:35.000Z' }] } }] }

        allow(@controller).to receive(:call_to_resource_catalog).and_return(catalog_response)
        allow(@controller).to receive(:call_to_data_collector).and_return(collector_response)

        get 'resources', params: { capability: 'temp',
                                   lat: '12.34', lon: '43.21',
                                   radius: '100',
                                   min_cap_value: 20, max_cap_value: 30 }
        hash_response_uuids = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(hash_response_uuids).to eq('resources' => [{ 'uuid' => '7', 'lat' => '40', 'lon' => '40' }])
      end
    end

    it 'when any service is unavailable, should fail' do
      allow(@controller).to receive(:call_to_resource_catalog).and_raise

      get 'resources', params: { capability: 'temp' }

      expect(response.status).to eq(503)
    end
  end
end
