# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe ComponentsController, type: :controller do
  subject { response }
  let(:json) { JSON.parse(response.body) }
  describe '#create' do
    context 'correct requests' do
      before do
        stub_const('Platform::ResourceManager', double)
        cataloguer_response_body = {
          'data' => {
            'description' => 'A simple resource in São Paulo',
            'status' => 'stopped',
            'country' => 'Brazil',
            'state' => 'São Paulo',
            'uri' => 'example2.com',
            'postal_code' => '05508-090',
            'id' => 677,
            'lon' => -46.731386,
            'updated_at' => '2016-10-28T13:25:16.069Z',
            'uuid' => '956a8ec9-bda7-45b3-85fc-8762cee2879a',
            'city' => 'São Paulo',
            'neighborhood' => 'Butantã',
            'capabilities' => [
              'environment_monitoring'
            ],
            'collect_interval' => 5,
            'created_at' => '2016-10-28T13:25:16.069Z',
            'lat' => -23.559616
          }
        }
        cataloguer_response = double
        allow(cataloguer_response).to receive(:code).and_return(201)
        allow(cataloguer_response).to receive(:body).and_return(JSON(cataloguer_response_body))
        allow(Platform::ResourceManager).to receive(:register_resource).and_return(cataloguer_response)

        process :create, method: :post, params: {
          data: {
            lat: -23.559616,
            lon: -46.731386,
            status: 'stopped',
            description: 'A simple resource in São Paulo',
            capabilities: ['environment_monitoring']
          }
        }
      end

      it { is_expected.to have_http_status(:created) }
    end

    context 'Resource Cataloguer unavailable' do
      before do
        stub_const('Platform::ResourceManager', double)
        allow(Platform::ResourceManager).to receive(:register_resource).and_return(nil)

        process :create, method: :post, params: {
          data: {
            lat: -23.559616,
            lon: -46.731386,
            status: 'stopped',
            description: 'A simple resource in São Paulo',
            capabilities: ['environment_monitoring']
          }
        }
      end

      it { is_expected.to have_http_status(503) }
      it 'returns an error message' do
        body = JSON.parse(response.body)
        expect(body['message']).to eq('Register service is unavailable')
      end
    end
  end

  describe '#data_specific' do
    context 'post one observed data to existing capability' do
      let(:capability) { 'environment_monitoring' }
      before do
        allow_any_instance_of(DataManager).to receive(:setup).and_return(true)
        allow(DataManager.instance).to receive(:publish_resource_data) { true }

        process :data_specific, method: :post, params: {
          id: 10,
          capability: capability,
          data: [{ temperature: '12.8', timestamp: '20/08/2016T10:27:40' }]
        }
      end

      it { is_expected.to have_http_status(201) }
      it 'should update component observation' do
      end
    end
  end

  describe '#data' do
    context 'post observed data of two existing capability' do
      before do
        allow_any_instance_of(DataManager).to receive(:setup).and_return(true)
        allow(DataManager.instance).to receive(:publish_resource_data) { true }
        json = {
          id: 10,
          data: {
            environment_monitoring: [
              { temperature: '20.2', humidity: '67', timestamp: '20/08/2016T10:27:40' }
            ]
          }
        }

        process :data, method: :post, params: json
      end

      it { is_expected.to have_http_status(201) }

      it 'should update component temperature observation' do
      end

      it 'should update component humidity observation' do
      end
    end

    context 'invalid input' do
      before do
        allow_any_instance_of(DataManager).to receive(:setup).and_return(true)
        allow(DataManager.instance).to receive(:publish_resource_data) { true }
        json = {
          id: 10,
          data: {
            environment_monitoring: { temperature: '20.2', timestamp: '20/08/2016T10:27:40' },
            humidity: { value: '67', timestamp: '30/10/2016T06:32:03' }
          }
        }

        process :data, method: :post, params: json
      end

      it { is_expected.to have_http_status(400) }
    end
  end
end
