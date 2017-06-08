require 'rails_helper'
require 'json'

describe ActuatorController, :type => :controller do
  let(:json) {JSON.parse(response.body)}
  let(:semaphore) do
    PlatformResource.create!(uuid: '1', status: 'active', capabilities: ['semaphore'])
  end
  let(:lamppost) do
    PlatformResource.create!(uuid: '2', status: 'active', capabilities: ['illuminate'])
  end

  describe '#actuate' do
    before(:each) do
      @semaphore = semaphore
      @lamppost = lamppost
    end

    context "with valid parameters" do
      before do
          allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
        params = {
          data: [
            {uuid: "1", capabilities: {illuminate: "moderate"}},
            {uuid: "1", capabilities: {semaphore: "red"}},
            {uuid: "2", capabilities: {illuminate: "moderate"}},
            {uuid: "2", capabilities: {illuminate: nil}},
            {uuid: "-1", capabilities: {semaphore: "green"}},
          ]
        }
        process :actuate, method: :put, params: params, as: :json
      end
 
      it "returns success" do
        expect(response).to have_http_status(:success)
      end

      it "has two successful command requests" do
        expect(json["success"].count).to eq(2)
      end

      it "has three failed command requests" do
        expect(json["failure"].count).to eq(3)
      end

      it "returns a pending command to success requests" do
        json["success"].each do |success|
          expect(success).to have_key("_id")
          expect(success).to have_key("uuid")
          expect(success).to have_key("capability")
          expect(success).to have_key("created_at")
          expect(success).to have_key("updated_at")
          expect(success).to have_key("value")
          expect(success).to have_key("status")
          expect(success["status"]).to eq("pending")
        end
      end

      it "returns a detailed error description for each failure" do
        json["failure"].each do |failure|
          expect(failure).to have_key("uuid")
          expect(failure).to have_key("capability")
          expect(failure).to have_key("value")

          expect(failure).to have_key("error")
          expect(failure).to have_key("code")
        end
      end

      it "does not returns a command object for failed requests" do
        json["failure"].each do |failure|
          expect(failure).to_not have_key("_id")
          expect(failure).to_not have_key("status")
          expect(failure).to_not have_key("created_at")
          expect(failure).to_not have_key("updated_at")
        end
      end
    end

    context "with multiple valid requests" do
      before do
        allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
        params = {
          data: [
            {
              uuid: "1",
              capabilities: {illuminate: "moderate", semaphore: "red"}
            },
            {
              uuid: "2",
              capabilities: {illuminate: nil, semaphore: "red"}
            },
            {
              uuid: "-1",
              capabilities: {semaphore: "green", illuminate: "low"}
            },
          ]
        }
        process :actuate, method: :put, params: params, as: :json
      end
  
      it "returns success" do
        expect(response).to have_http_status(:success)
      end

      it "has two successful command requests" do
        expect(json["success"].count).to eq(1)
      end

      it "has four failed command requests" do
        expect(json["failure"].count).to eq(5)
      end

      it "returns a pending command to success requests" do
        json["success"].each do |success|
          expect(success).to have_key("_id")
          expect(success).to have_key("uuid")
          expect(success).to have_key("capability")
          expect(success).to have_key("created_at")
          expect(success).to have_key("updated_at")
          expect(success).to have_key("value")
          expect(success).to have_key("status")
          expect(success["status"]).to eq("pending")
        end
      end

      it "returns a detailed error description for each failure" do
        json["failure"].each do |failure|
          expect(failure).to have_key("uuid")
          expect(failure).to have_key("capability")
          expect(failure).to have_key("value")

          expect(failure).to have_key("error")
          expect(failure).to have_key("code")
        end
      end

      it "does not returns a command object for failed requests" do
        json["failure"].each do |failure|
          expect(failure).to_not have_key("_id")
          expect(failure).to_not have_key("status")
          expect(failure).to_not have_key("created_at")
          expect(failure).to_not have_key("updated_at")
        end
      end
    end

    context "with invalid parameters" do
      it "requires 'data' key" do
        process :actuate,
          method: :put,
          params: {uuid: '1',capabilities: {semaphore: 'green'}}

        expect(response).to have_http_status(400)
        expect(json).to have_key("error")
      end
    end
  end
end
