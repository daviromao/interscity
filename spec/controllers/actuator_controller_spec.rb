require 'rails_helper'
require 'json'

describe ActuatorController, :type => :controller do

  describe '#resources' do

    before(:all) do
      Resource.create(name:"trafficlight",uri:"123.123.123.123",uuid:"1")
      Resource.create(name:"trafficlight1",uri:"123.123.123.120",uuid:"2")
      Resource.create(name:"trafficlight2",uri:"123.123.123.112",uuid:"3")
    end

    it 'should return status 400 (Bad Request)' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:"1",capability: {name:'trafficlight',value:'blue'}}.to_json
      json_payload = {uuid:'1',capability: 'trafficlight'}
      put :exec, json_payload,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'should return status 201  and execute the capability' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:"1",capability: {name:'trafficlight',value:'green'}}.to_json
      json_payload = {uuid:'1',capability: 'trafficlight'}
      put :exec, json_payload,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'should return status 400  missing parameters' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {capability: {name:'trafficlight',value:'green'}}.to_json
      json_payload = {uuid:'1',capability: 'trafficlight'}
      put :exec, json_payload,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Wrong json format and should return 400' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = "{capabilit afficlight',value:'green'}}"
      json_payload = {uuid:'1',capability: 'trafficlight'}
      put :exec, json_payload,'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return status 200' do
      json_payload = {uuid:'1',capability: 'trafficlight'}
      get :status, json_payload
      expect(response.status).to eq(200)
      expect(response.body).to eq ('green')
    end

    it 'Should return status 400 because a wrong capability was used' do
      json_payload = {uuid:'1',capability: 'temperature'}
      get :status, json_payload
      expect(response.status).to eq(400)
    end

    it 'Should return 201 and create a new resource' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:'10',name:'trafficlight',uri:'123.123.123.2'}.to_json

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'Should return 400, missing uuid' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {name:'trafficlight',uri:'123.123.123.2'}.to_json

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 400, wrong json format' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = "{capabilit afficlight',value:'green'}}"

      post :create, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(400)
    end

    it 'Should return 201 and update a resource data' do
      request.env["HTTP_ACCEPT"] = "application/json"
      request.env["RAW_POST_DATA"] = {uuid:'1',name:'trafficlight',uri:'123.123.123.2'}.to_json

      put :update, 'CONTENT_TYPE' => 'application/json'
      expect(response.status).to eq(201)
    end

    it 'Should return 400 and update a resource data' do
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