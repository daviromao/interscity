# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe BasicResourcesController, :integration, type: :controller do
  let!(:temperature_sensor) { Capability.create(name: 'temperature', function: Capability.sensor_index) }
  let!(:semaphore_actuator) { Capability.create(name: 'semaphore', function: Capability.actuator_index) }
  let!(:parking_information) { Capability.create(name: 'parking slot', function: Capability.information_index) }
  let(:json) { JSON.parse(response.body) }
  describe '#create' do
    context 'successful' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        BasicResource.destroy_all
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: -23.559616,
                 lon: -46.731386,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['temperature']
               }
             },
             format: :json
      end

      it { expect(response.status).to eq(201) }
      it 'is expected to return the location of the new resource in the header' do
        expect(response.location).to match(%r{resources/\d+})
      end
      it 'is expected to return the resource in JSON' do
        expect(json['data']['id'].class).to eq(Integer)
        expect(json['data']['uri']).to eq('example.com')
        expect(json['data']['lat']).to eq(-23.559616)
        expect(json['data']['lon']).to eq(-46.731386)
        expect(json['data']['status']).to eq('stopped')
        expect(json['data']['collect_interval']).to eq(5)
        expect(json['data']['description']).to eq('I am a dummy sensor')
        expect(json['data']['capabilities']).to eq(['temperature'])
      end

      xit 'is expected to automatically fill in location parameters' do
        resource = BasicResource.last
        expect(resource.country).to eq('Brazil')
        expect(resource.state).to eq('São Paulo')
        expect(resource.neighborhood).to eq('Butantã')
        expect(resource.postal_code).to match(/\d+-\d+/)
      end

      it 'is expected to create a resource' do
        expect(BasicResource.count).to be(1)
      end

      it 'generates a uuid to the new resource' do
        resource = BasicResource.last
        expect(resource.uuid).to_not be_nil
      end

      context 'capabilities' do
        subject { BasicResource.last.capabilities }
        it { is_expected.to include(temperature_sensor) }
      end
    end

    context 'when the client provides the uuid' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        BasicResource.destroy_all
      end

      it 'saves the resource with valid uuid' do
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: -23.559616,
                 uuid: 'bad85eb9-0713-4da7-8d36-07a8e4b00eab',
                 lon: -46.731386,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['temperature']
               }
             },
             format: :json

        expect(response.status).to eq(201)
        expect(json['data']['uuid']).to eq('bad85eb9-0713-4da7-8d36-07a8e4b00eab')
      end

      it 'does not save the resource when the uuid is invalid' do
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: -23.559616,
                 uuid: 'not_valid_UUID',
                 lon: -46.731386,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['temperature']
               }
             },
             format: :json

        expect(response.status).to eq(422)
      end

      it 'does not save the resource when the uuid is not unique' do
        BasicResource.create!(
          uri: 'example.com',
          lat: -23.559616,
          lon: -46.731386,
          status: 'active',
          uuid: 'bad85eb9-0713-4da7-8d36-07a8e4b00eab',
          description: 'I am a dummy sensor',
          capabilities: [Capability.last]
        )

        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: -23.559616,
                 uuid: 'bad85eb9-0713-4da7-8d36-07a8e4b00eab',
                 lon: -46.731386,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['temperature']
               }
             },
             format: :json

        expect(response.status).to eq(422)
      end
    end

    context 'successful in a remote location' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        BasicResource.destroy_all
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: -42,
                 lon: -15,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['temperature']
               }
             },
             format: :json
      end

      it { expect(response.status).to eq(201) }
      it 'is expected to return the location of the new resource in the header' do
        expect(response.location).to match(%r{resources/\d+})
      end
      it 'is expected to return the resource in JSON' do
        expect(json['data']['id'].class).to eq(Integer)
        expect(json['data']['uri']).to eq('example.com')
        expect(json['data']['lat']).to eq(-42)
        expect(json['data']['lon']).to eq(-15)
        expect(json['data']['status']).to eq('stopped')
        expect(json['data']['collect_interval']).to eq(5)
        expect(json['data']['description']).to eq('I am a dummy sensor')
      end

      it 'is expected to have no values for location' do
        resource = BasicResource.last
        expect(resource.country).to eq(nil)
        expect(resource.state).to eq(nil)
        expect(resource.neighborhood).to eq(nil)
        expect(resource.postal_code).to eq(nil)
      end

      it 'is expected to create a resource' do
        expect(BasicResource.count).to be(1)
      end

      it 'generates a uuid to the new resource' do
        resource = BasicResource.last
        expect(resource.uuid).to_not be_nil
      end
    end

    context 'fails due to bad parameters' do
      before :each do
        BasicResource.destroy_all
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: 20,
                 lon: 20
                 # no status
               }
             },
             format: :json
      end
      it { expect(response.status).to eq(422) }
    end

    context 'fails due to inexistent capability' do
      before :each do
        BasicResource.destroy_all
        post 'create',
             params: {
               data: {
                 uri: 'example.com',
                 lat: 20,
                 lon: 20,
                 status: 'stopped',
                 collect_interval: 5,
                 description: 'I am a dummy sensor',
                 capabilities: ['laser_gun']
               }
             },
             format: :json
      end
      it { expect(response.status).to eq(422) }
    end

    context 'fails due to malformed json' do
      def create_resource(params = {})
        default_params = {
          data: {
            uri: 'example.com',
            lat: 20,
            lon: 20,
            status: 'stopped',
            description: 'I am a dummy sensor',
            capabilities: ['temperature']
          }
        }

        default_params[:data].merge!(params)

        post 'create', params: default_params, format: :json
      end

      it 'has empty latitude' do
        create_resource("lat": nil)
        expect(response.status).to eq(422)
        expect(json['error']).to eq("Validation failed: Lat can't be blank, Lat is not a number")
      end

      it 'has empty longitude' do
        create_resource("lon": nil)
        expect(response.status).to eq(422)
        expect(json['error']).to eq("Validation failed: Lon can't be blank, Lon is not a number")
      end

      it 'has empty status' do
        create_resource("status": nil)
        expect(response.status).to eq(422)
        expect(json['error']).to eq("Validation failed: Status can't be blank")
      end
    end
  end

  describe '#index_sensors' do
    before :each do
      get 'index_sensors', format: :json
    end

    it { expect(response.status).to eq(200) }

    it 'is expected to return an empty JSON list' do
      expect(json['resources']).to eq([])
    end
  end

  describe '#index_actuators' do
    before :each do
      get 'index_actuators', format: :json
    end

    it { expect(response.status).to eq(200) }

    it 'is expected to return an empty JSON list' do
      expect(json['resources']).to eq([])
    end
  end

  describe '#show' do
    let!(:resource) do
      BasicResource.create(uri: 'qwedsa.com',
                           lat: 20,
                           lon: 20,
                           status: 'stopped',
                           collect_interval: 5,
                           description: 'I am a dummy sensor',
                           capabilities: [temperature_sensor])
    end

    context 'successful' do
      before :each do
        get :show, params: { uuid: resource.uuid }, format: :json
      end

      it { expect(response.status).to eq(200) }

      it 'is expected to return the resource in JSON' do
        expect(json['data']['uri']).to eq(resource.uri)
        expect(json['data']['uuid']).to eq(resource.uuid)
        expect(json['data']['lat']).to eq(resource.lat)
        expect(json['data']['lon']).to eq(resource.lon)
        expect(json['data']['status']).to eq(resource.status)
        expect(json['data']['collect_interval']).to eq(resource.collect_interval)
        expect(json['data']['description']).to eq(resource.description)
        expect(json['data']['capabilities']).to eq(['temperature'])
      end
    end

    context 'fails' do
      before :each do
        get :show, params: { uuid: 'really not the right uuid' }, format: :json
      end

      it { expect(response.status).to eq(404) }
    end
  end

  describe '#update' do
    let!(:resource) do
      BasicResource.create(lat: 20,
                           lon: 20,
                           status: 'stopped',
                           collect_interval: 5,
                           description: 'I am a dummy sensor',
                           uri: 'qwedsa.com',
                           capabilities: [temperature_sensor])
    end
    context 'successful' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        put :update, params: {
          uuid: resource.uuid, data: {
            uri: 'changed.com',
            lat: -23.2237,
            lon: -45.9009,
            collect_interval: 1,
            capabilities: ['temperature']
          }
        }, format: :json
      end

      it { expect(response.status).to eq(200) }
      it 'is expected to update resource data' do
        updated_resource = BasicResource.find(resource.id)
        expect(updated_resource.uri).to eq('changed.com')
        expect(updated_resource.status).to eq('stopped')
        expect(updated_resource.collect_interval).to eq(1)
        expect(updated_resource.description).to eq('I am a dummy sensor')
        expect(updated_resource.capabilities).to eq([temperature_sensor])
      end

      xit 'is expected to automatically update location parameters' do
        updated_resource = BasicResource.find(resource.id)
        expect(updated_resource.city).to eq('São José dos Campos')
        expect(updated_resource.state).to eq('São Paulo')
        expect(updated_resource.country).to eq('Brazil')
      end
    end

    context 'fails due to bad parameters' do
      before :each do
        put(
          :update,
          params: {
            uuid: resource.uuid,
            data: { uri: 'changed.com', lat: 'not a number', lon: -40, collect_interval: 1 }
          },
          format: :json
        )
      end

      it { expect(response.status).to eq(422) }
    end

    context 'fails due to inexistant capability' do
      before :each do
        put :update, params: { uuid: resource.uuid, data: { capabilities: ['laser gun'] } }, format: :json
      end

      it { expect(response.status).to eq(422) }
    end
  end

  describe '#search' do
    let!(:resource1) do
      BasicResource.create(
        description: 'just a resource',
        lat: -23.559616,
        lon: -46.731386,
        status: 'stopped',
        collect_interval: 5,
        uri: 'example.com',
        capabilities: [semaphore_actuator]
      )
    end
    let!(:resource2) do
      BasicResource.create(
        description: 'just another resource',
        lat: -23,
        lon: -46,
        status: 'live',
        collect_interval: 20,
        uri: 'saojose.com',
        capabilities: [temperature_sensor]
      )
    end
    let!(:resource3) do
      BasicResource.create(
        description: 'just another another resource',
        lat: -42,
        lon: -15,
        status: 'live',
        collect_interval: 1,
        uri: 'nowhere.com',
        capabilities: [parking_information]
      )
    end
    let!(:resources) do
      BasicResource.all
    end
    context 'successful' do
      before :each do
        get :search, params: { status: 'stopped', lat: -23, lon: -46, radius: 200_000, capability: 'semaphore' }
      end
      context 'response' do
        subject { response.status }
        it { is_expected.to be 200 }
      end
      context 'result' do
        subject { response.body }
        it { is_expected.to include(resource1.uuid) }
      end
    end
    context 'failure' do
      before :each do
        # simulate error
        expect(BasicResource).to receive(:all).and_raise
        get :search, params: { status: 'stopped', lat: -23, lon: -46, radius: 200_000, capability: 'semaphore' }
      end
      context 'response' do
        subject { response.status }
        it { is_expected.to be 422 }
      end
    end

    context 'when params vary' do
      context 'with only status' do
        before :each do
          get :search, params: { status: 'stopped' }
        end

        context 'response' do
          subject { response.status }
          it { is_expected.to be 200 }
        end

        context 'result' do
          subject { response.body }

          it { is_expected.to include(resource1.uuid) }
          it { is_expected.to_not include(resource2.uuid) }
        end
      end

      context 'with capabilty' do
        before :each do
          get :search, params: { capability: 'semaphore' }
        end

        context 'response' do
          subject { response.status }
          it { is_expected.to be 200 }
        end

        context 'result' do
          subject { response.body }

          it { is_expected.to include(resource1.uuid) }
          it { is_expected.to_not include(resource2.uuid) }
        end
      end

      context 'with lat and lon' do
        before :each do
          get :search, params: { lat: -23, lon: -46 }
        end

        context 'response' do
          subject { response.status }
          it { is_expected.to be 200 }
        end

        context 'result' do
          subject { response.body }

          it { is_expected.to include(resource2.uuid) }
          it { is_expected.to_not include(resource1.uuid) }
        end
      end

      context 'with lat, lon and radius' do
        before :each do
          get :search, params: { lat: -23.4, lon: -46, radius: 200_000 }
        end

        context 'response' do
          subject { response.status }
          it { is_expected.to be 200 }
        end

        context 'result', focus: true do
          subject { response.body }

          it { is_expected.to include(resource1.uuid) }
          it { is_expected.to include(resource2.uuid) }
          it { is_expected.to_not include(resource3.uuid) }
        end
      end
    end
  end
end
