require 'rails_helper'
require 'json'

describe ActuatorController, :type => :controller do

  describe '#resources' do

    before(:all) do
      Resource.create(name:"trafficlight",uri:"123.123.123.123",uuid:"1")
      Resource.create(name:"trafficlight1",uri:"123.123.123.120",uuid:"2")
      Resource.create(name:"trafficlight2",uri:"123.123.123.112",uuid:"3")
    end

    it 'Should return status 400 (Bad Request). A traffic light can not turn blue.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:"1",capability: {name:'trafficlight',value:'blue'}}.to_json
      url_params = {uuid:'1',capability: 'trafficlight'}
      put :exec, url_params,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return status 201. The traffict light actuator should be able to turn green.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:"1",capability: {name:'trafficlight',value:'green'}}.to_json
      url_params = {uuid:'1',capability: 'trafficlight'}
      put :exec, url_params,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'Should return status 400. The UUID is needed to find the specific resource from the database  missing parameters.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {capability: {name:'trafficlight',value:'green'}}.to_json
      url_params = {uuid:'1',capability: 'trafficlight'}
      put :exec, url_params,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 400. Wrong json format to update a resource state.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = "{capabilit afficlight',value:'green'}}"
      url_params = {uuid:'1',capability: 'trafficlight'}
      put :exec, url_params,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return status 200. Client request for a resource status.' do
      url_params = {uuid:'1',capability: 'trafficlight'}
      get :status, url_params
      expect(response.status).to eq(200)
      expect(response.body).to eq ('green')
    end

    it 'Should return status 400 because a wrong capability was used' do
      url_params = {uuid:'1',capability: 'temperature'}
      get :status, url_params
      expect(response.status).to eq(400)
    end

    it 'Should return 201. Successful resource creation from the Resource Catalog.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:'10',name:'trafficlight',uri:'123.123.123.2'}.to_json

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'Should return 400. Resource creation needs the uuid.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {name:'trafficlight',uri:'123.123.123.2'}.to_json

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 400. Wrong json format for the resource creation form.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = "{capabilit afficlight',value:'green'}}"

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 201 and update the resource data' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:'1',name:'trafficlight',uri:'123.123.123.2'}.to_json

      put :update, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'Should return 400. Wrong json format for the resource data update.' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = "{capabilit afficlight',value:'green'}}"

      put :update, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 400, missing uuid' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {name:'trafficlight',uri:'123.123.123.2'}.to_json

      put :update, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

  end
end