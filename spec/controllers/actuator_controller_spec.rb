require 'rails_helper'
require 'json'

describe ActuatorController, :type => :controller do

  describe '#resources' do

    before(:each) do
      @controller = ActuatorController.new

      allow(@controller).to receive(:call_to_actuator_cap_status).and_return({})

      res = PlatformResource.create!(uri: 'traffic_light_url', uuid: '1', collect_interval: 60, status: 'running')
      cap = res.capabilities.create!(name: 'trafficlight')
      ActuatorValue.create!(value: 'green', capability_id: cap.id, platform_resource_id: res.id)
    end

    it 'Should return status 405 code for the specific resource. Traffic light can not turn blue.' do
      json_request = {data: [{uuid: '1', capabilities:{trafficlight: 'blue'}}]}
      service_response = {success:[],failure:[{uuid:'1', capability: 'trafficlight', code:405,  message: "Error"}]}.to_json

      fake_exception = RestClient::ExceptionWithResponse.new
      resp = RestClient::Response
      resp.class.module_eval { attr_accessor :code}
      resp.class.module_eval { attr_accessor :message}
      resp.code = 405
      resp.message = 'Error'
      fake_exception.response = resp

      allow(@controller).to receive(:call_to_actuator_actuate).and_raise(fake_exception)
      put :actuate, params: json_request
      expect(response.status).to eq(200)
      expect(response.body).to eq(service_response)
    end

    it 'Should return status 200. Traffic light actuator should be able to turn green.' do
      json_request = {
        data: [
          {
            uuid: '1',
            capabilities: {trafficlight: 'green'}
          }
        ]
      }

      service_response = {
        'success' => [
          {
            'capability' => 'trafficlight',
            'state' => 'green',
            'code' => 200,
            'uuid' => '1'
          }],
          'failure' => []}

      actuator_response = {
        data: {
          state: 'green'
        },
        code: 200
      }.to_json


      allow(@controller).to receive(:call_to_actuator_actuate).and_return(actuator_response)
      put :actuate, params: json_request
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(service_response)
    end

    it 'Should return status 404. Not existing resource.' do
      json_request = {
        data: [
          {
            uuid: '-1',
            capabilities: {trafficlight: 'green'}
          }
        ]
      }

      service_response = {
        'success' => [],
        'failure' => [{
          'capability' => 'trafficlight',
          'code' => 404,
          'uuid' => '-1',
          'message' => 'Resource not found'
        }]}

      actuator_response = {
        data: {
          state: 'green'
        },
        code: 200
      }.to_json


      allow(@controller).to receive(:call_to_actuator_actuate).and_return(actuator_response)
      put :actuate, params: json_request
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(service_response)
    end

    it 'Should return 200. Respond with error 500 when occur an internal server error while proccessing a resource actuation.' do
      json_request = {data: [{uuid: '1', capabilities:{trafficlight: 'blue'}}]}
      service_response = {success:[],failure:[{uuid:'1', capability: 'trafficlight', code:500,  message: "Exception"}]}.to_json

      allow(@controller).to receive(:call_to_actuator_actuate).and_raise(Exception)
      put :actuate, params: json_request
      expect(response.status).to eq(200)
      expect(response.body).to eq(service_response)
    end

    it 'Should return 500. Respond with error 500 when occur a general internal server error.' do
      json_request = {data: [{uuid: '1', capabilities:{trafficlight: 'blue'}}]}
      service_response = {code:'InternalError',  message: "Exception"}.to_json

      allow(@controller).to receive(:execute_actuation).and_raise(Exception)
      put :actuate, params: json_request
      expect(response.status).to eq(500)
      expect(response.body).to eq(service_response)
    end 

    it 'Should return 400. Wrong json format to update a resource state.' do
      json_request = {capability: 'trafficlight', value: 'green'}
      put :actuate, params: json_request
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

    it 'Should return status 404 - Not existing resource.' do
      url_params = {uuid: '1', capability: 'temperature'}
      service_response = {code:'NotFound',message:'Actuator not found'}
      get :cap_status, params: url_params
      expect(response.status).to eq(404)
      expect(response.body).to eq(service_response.to_json)
    end

  end
end
