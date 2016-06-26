require 'rails_helper'
require 'json'

describe ActuatorController, :type => :controller do

  describe '#resources' do

    before(:each) do
      @controller = ActuatorController.new

      allow(@controller).to receive(:call_to_actuator_cap_status).and_return({})

      res = Resource.create(name: 'Traffic Light', uri: 'traffic_light_url', uuid: '1')
      cap = res.capabilities.create(name: 'trafficlight')
      ActuatorValue.create(value: 'green', capability_id: cap.id, resource_id: res.id)

    end

    it 'Should return status 405 code for the specific resource. Traffic light can not turn blue.' do
      json_request = {data: [{uuid: '1', trafficlight: 'blue'}]}
      service_response = {success:[],failure:[{capability: {name: 'trafficlight', value: 'blue'},code:405,uuid:'1'}]}.to_json
      actuator_response = {capability: {name: 'trafficlight', value: 'blue'},code:405}.to_json
      allow(@controller).to receive(:call_to_actuator_actuate).and_return(actuator_response)
      put :actuate, json_request, format: :json
      expect(response.status).to eq(200)
      expect(response.body).to eq(service_response)
    end

    it 'Should return status 200. Traffic light actuator should be able to turn green.' do
      json_request = {data: [{uuid: '1', trafficlight: 'green'}]}
      service_response = {success:[{capability: {name: 'trafficlight', value: 'green'},code:200,uuid:'1'}],failure:[]}.to_json
      actuator_response = {capability: {name: 'trafficlight', value: 'green'},code:200}.to_json
      allow(@controller).to receive(:call_to_actuator_actuate).and_return(actuator_response)
      put :actuate, json_request, format: :json
      expect(response.status).to eq(200)
      expect(response.body).to eq(service_response)
    end

    it 'Should return 400. Wrong json format to update a resource state.' do
      json_request = "{capabilit afficlight',value:'green'}}"
      put :actuate, json_request, format: :json
      expect(response.status).to eq(400)
    end

    it 'Should return status 200. Client requests a resource status.' do
      url_params = {uuid: '1', capability: 'trafficlight'}
      actuator_response = {uuid:'1',capabilities:[name:'trafficlight',value:'green'],code:200}
      allow(@controller).to receive(:call_to_actuator_cap_status).and_return(actuator_response)

      get :cap_status, params: url_params

      expect(response.status).to eq(200)
      expect(response.body).to eq (actuator_response.to_json)
    end

    it 'Should return status 400. Wrong capability name.' do
      url_params = {uuid: '1', capability: 'temperature'}
      service_response = {code:'NotFound',message:'Actuator not found'}
      get :cap_status, params: url_params
      debugger
      expect(response.status).to eq(404)
      expect(response.body).to eq(service_response.to_json)
    end

=begin
    it 'Should return 201. Successful resource creation from the BasicResource Catalog.' do
      json_request = {data:{uuid: '10', name: 'trafficlight', uri: '123.123.123.2'}}
      post :create, json_request, format: :json
      expect(response.status).to eq(201)
    end

    it 'Should return 400. BasicResource creation needs the uuid.' do
      json_request = {data:{name: 'trafficlight', uri: '123.123.123.2'}}
      post :create, json_request, format: :json
      expect(response.status).to eq(400)
    end

    it 'Should return 400. Wrong json format for the resource creation form.' do
      json_request = "{capabilit afficlight',value:'green'}}"
      post :create, json_request, format: :json
      expect(response.status).to eq(400)
    end

    it 'Should return 200 and update the resource data' do
      json_request = {data:{uuid: '1', name: 'trafficlight', uri: '123.123.123.2'}}
      put :update, json_request,format: :json
      expect(response.status).to eq(200)
    end

    it 'Should return 400. Wrong json format for the resource data update.' do
      json_request = "{capabilit afficlight',value:'green'}}"
      put :update, json_request,format: :json
      expect(response.status).to eq(400)
    end

    it 'Should return 400, missing uuid' do
      json_request = {data:{name: 'trafficlight', uri: '123.123.123.2'}}
      put :update,json_request,format: :json
      expect(response.status).to eq(400)
    end
=end

  end
end