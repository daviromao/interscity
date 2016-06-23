require 'rails_helper'
require 'spec_helper'

describe BasicResourcesController do
  let!(:temperature_sensor) { Capability.create(name: "temperature", function: Capability.sensor_index) }
  let!(:semaphore_actuator) { Capability.create(name: "semaphore", function: Capability.actuator_index) }
  let!(:parking_information) { Capability.create(name: "parking slot", function: Capability.information_index) }
  let(:json) {JSON.parse(response.body)}
  describe '#create' do
    context 'successful' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        BasicResource.destroy_all
        post 'create',
          params: {
            data: {
              uri: "example.com",
              lat: -23.559616,
              lon: -46.731386,
              status: "stopped",
              collect_interval: 5,
              description: "I am a dummy sensor",
              capabilities: ["temperature"]
            }
          },
        format: :json
      end

      it { expect(response.status).to eq(201) }
      it 'is expected to return the location of the new resource in the header' do
        expect(response.location).to match(/resources\/\d+/)
      end
      it 'is expected to return the resource in JSON' do
        expect(json["data"]["id"].class).to eq(Fixnum)
        expect(json["data"]["uri"]).to eq("example.com")
        expect(json["data"]["lat"]).to eq(-23.559616)
        expect(json["data"]["lon"]).to eq(-46.731386)
        expect(json["data"]["status"]).to eq('stopped')
        expect(json["data"]["collect_interval"]).to eq(5)
        expect(json["data"]["description"]).to eq("I am a dummy sensor")
        expect(json["data"]["capabilities"]).to eq(["temperature_sensor"])
      end

      it 'is expected to automatically fill in location parameters' do
        resource = BasicResource.last
        expect(resource.country).to eq("Brazil")
        expect(resource.state).to eq("São Paulo")
        expect(resource.neighborhood).to eq("Butantã")
        expect(resource.postal_code).to eq("05508-090")
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
        it { is_expected.to include(temperature_sensor)}
      end
    end

    context 'successful in a remote location' do
      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        BasicResource.destroy_all
        post 'create',
          params: {
            data: {
              uri: "example.com",
              lat: -42,
              lon: -15,
              status: "stopped",
              collect_interval: 5,
              description: "I am a dummy sensor",
              capabilities: ["temperature"]
            }
          },
        format: :json
      end

      it { expect(response.status).to eq(201) }
      it 'is expected to return the location of the new resource in the header' do
        expect(response.location).to match(/resources\/\d+/)
      end
      it 'is expected to return the resource in JSON' do
        expect(json["data"]["id"].class).to eq(Fixnum)
        expect(json["data"]["uri"]).to eq("example.com")
        expect(json["data"]["lat"]).to eq(-42)
        expect(json["data"]["lon"]).to eq(-15)
        expect(json["data"]["status"]).to eq('stopped')
        expect(json["data"]["collect_interval"]).to eq(5)
        expect(json["data"]["description"]).to eq("I am a dummy sensor")
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
              uri: "example.com",
              lat: 20,
              lon: 20,
              status: "stopped",
              # no collect_interval
          },
        },
        format: :json
      end
      it { expect(response.status).to eq(422) }
    end

    context 'fails due to inexistant capability' do
      before :each do
        BasicResource.destroy_all
        post 'create',
          params: {
            data: {
              uri: "example.com",
              lat: 20,
              lon: 20,
              status: "stopped",
              collect_interval: 5,
              description: "I am a dummy sensor",
              capabilities: ["laser_gun"]
          },
        },
        format: :json
      end
      it { expect(response.status).to eq(422) }
    end
  end

  describe '#index_sensors' do

    before :each do
      get 'index_sensors', format: :json
    end

    it { expect(response.status).to eq(200) }

    it 'is expected to return an empty JSON list' do
      expect(response.body).to eq("[]")
    end

  end

  describe '#index_actuators' do

    before :each do
      get 'index_actuators', format: :json
    end

    it { expect(response.status).to eq(200) }

    it 'is expected to return an empty JSON list' do
      expect(response.body).to eq("[]")
    end

  end

  describe '#show' do
    let!(:resource) { BasicResource.create(uri: "qwedsa.com",
      lat: 20,
      lon: 20,
      status: "stopped",
      collect_interval: 5,
      description: "I am a dummy sensor",
      capabilities: [temperature_sensor])}

    context 'successful' do
      before :each do
        get :show, params: {uuid: resource.uuid}, format: :json
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
        expect(json['data']['capabilities']).to eq(['temperature_sensor'])
      end
    end

    context 'fails' do
      before :each do
        get :show, params: {uuid: "really not the right uuid"}, format: :json
      end

      it { expect(response.status).to eq(404) }
    end

  end

  describe '#update' do
    let!(:resource) { BasicResource.create(lat: 20,
      lon: 20,
      status: "stopped",
      collect_interval: 5,
      description: "I am a dummy sensor",
      uri: "qwedsa.com",
      capabilities: [temperature_sensor])}
    context 'successful' do

      before :each do
        allow(controller).to receive(:notify_resource).and_return(true)
        put :update, params: {uuid: resource.uuid, data: {uri: "changed.com", lat: -23, lon: -46, collect_interval: 1, capabilities:["temperature"]}}, format: :json
      end

      it { expect(response.status).to eq(204) }
      it 'is expected to update resource data' do
        updated_resource = BasicResource.find(resource.id)
        expect(updated_resource.uri).to eq('changed.com')
        expect(updated_resource.lat).to eq(-23)
        expect(updated_resource.lon).to eq(-46)
        expect(updated_resource.status).to eq("stopped")
        expect(updated_resource.collect_interval).to eq(1)
        expect(updated_resource.description).to eq("I am a dummy sensor")
        expect(updated_resource.capabilities).to eq([temperature_sensor])
      end

      it 'is expected to automatically update location parameters' do
        updated_resource = BasicResource.find(resource.id)
        expect(updated_resource.postal_code).to eq(nil)
        expect(updated_resource.neighborhood).to eq(nil)
        expect(updated_resource.city).to eq("São José dos Campos")
        expect(updated_resource.state).to eq("São Paulo")
        expect(updated_resource.country).to eq("Brazil")
      end
    end

    context 'fails due to bad parameters' do
      before :each do
        put :update, params: {uuid: resource.uuid, data: {uri: "changed.com", lat: "not a number", lon: -40, collect_interval: 1}}, format: :json
      end

      it { expect(response.status).to eq(422) }
    end


    context 'fails due to inexistant capability' do
      before :each do
        put :update, params: {uuid: resource.uuid, data: {capabilities: ["laser gun"]}}, format: :json
      end

      it { expect(response.status).to eq(422) }
    end
  end

  describe '#search' do
    let!(:resource1) {
      BasicResource.create(
        description: "just a resource",
        lat: -23.559616,
        lon: -46.731386,
        status: "stopped",
        collect_interval: 5,
        uri: "example.com",
        capabilities: [semaphore_actuator]
      )
    }
    let!(:resource2) {
      BasicResource.create(
        description: "just another resource",
        lat: -23,
        lon: -46,
        status: "live",
        collect_interval: 20,
        uri: "saojose.com",
        capabilities: [temperature_sensor]
      )
    }
    let!(:resource3) {
      BasicResource.create(
        description: "just another another resource",
        lat: -42,
        lon: -15,
        status: "live",
        collect_interval: 1,
        uri: "nowhere.com",
        capabilities: [parking_information]
      )
    }
    let!(:resources) {
      BasicResource.all
    }
    context "successful" do
      before :each do
        get :search, params: { data: {status: "stopped", lat:-23, lon:-46, radius: 200, capability: "semaphore"} }
      end
      context 'response' do
        subject {response.status}
        it { is_expected.to be 200 }
      end
      context 'result' do
        subject { json["resources"] }
        it { is_expected.to include({ "uuid" => resource1.uuid, "lat" => resource1.lat, "lon" => resource1.lon}) }
      end
    end
    context "failure" do
      before :each do
        # simulate error
        expect(BasicResource).to receive(:all).and_raise
        get :search, params: { data: {status: "stopped", lat:-23, lon:-46, radius: 200, capability: "semaphore"} }
      end
      context 'response' do
        subject {response.status}
        it { is_expected.to be 422 }
      end
    end
  end
end
