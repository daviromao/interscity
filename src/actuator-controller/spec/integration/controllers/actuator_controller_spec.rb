# frozen_string_literal: true

require 'rails_helper'
require 'json'

describe ActuatorController, :integration, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:semaphore) do
    PlatformResource.create!(uuid: '1', status: 'active', capabilities: ['semaphore'])
  end
  let(:lamppost) do
    PlatformResource.create!(uuid: '2', status: 'active', capabilities: ['illuminate'])
  end

  describe '#index' do
    before do
      allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
      FactoryGirl.create(:valid_actuator_command, uuid: '1234', capability: 'semaphore')
      FactoryGirl.create(:processed_actuator_command, uuid: '1234', capability: 'illuminate')
      FactoryGirl.create(:processed_actuator_command, uuid: 'XPTO', capability: 'semaphore')
      FactoryGirl.create(:failed_actuator_command, uuid: 'XPTO', capability: 'semaphore')
      FactoryGirl.create(:rejected_actuator_command, uuid: '1234', capability: 'semaphore')
      FactoryGirl.create(:rejected_actuator_command, uuid: '1234', capability: 'semaphore')
    end

    it 'returns all commands' do
      get :index
      expect(json['commands'].count).to eq(6)
    end

    it 'set 2 commands per page on results' do
      params = { page: 1, per_page: 2 }
      get :index, params: params
      expect(json['commands'].count).to eq(2)
    end

    it 'returns the second page of results' do
      params = { page: 2, per_page: 5 }
      get :index, params: params
      expect(json['commands'].count).to eq(1)
    end

    it 'returns an empty array for big page number' do
      params = { page: 1000, per_page: 3 }
      get :index, params: params
      expect(json['commands'].count).to eq(0)
    end

    it 'returns commands sorted by creation date' do
      get :index
      commands = json['commands']
      more_recent = nil
      commands.each do |current_command|
        if more_recent.nil?
          more_recent = current_command
          next
        end

        expect(more_recent['created_at']).to be >= current_command['created_at']
        more_recent = current_command
      end
    end

    it 'returns processed commands for resource with uuid 1234' do
      params = { status: 'processed', uuid: '1234' }
      get :index, params: params
      expect(json['commands'].count).to eq(1)
    end

    it 'return semaphore commands for resource with uuid 1234' do
      params = { capability: 'semaphore', uuid: '1234' }
      get :index, params: params
      expect(json['commands'].count).to eq(3)
    end

    it 'returns rejected semaphore commands' do
      params = { capability: 'semaphore', status: 'rejected' }
      get :index, params: params
      expect(json['commands'].count).to eq(2)
    end

    it 'does not return any command' do
      params = { capability: 'random', status: 'rejected' }
      get :index, params: params
      expect(json['commands'].count).to eq(0)
    end

    it 'returns all commands for unpermitted params' do
      params = { random_filter: 'nothing', stts: 'rejected' }
      get :index, params: params
      expect(json['commands'].count).to eq(6)
    end
  end

  describe '#create' do
    before(:each) do
      @semaphore = semaphore
      @lamppost = lamppost
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
        params = {
          data: [
            { uuid: '1', capabilities: { illuminate: 'moderate' } },
            { uuid: '1', capabilities: { semaphore: 'red' } },
            { uuid: '2', capabilities: { illuminate: 'moderate' } },
            { uuid: '2', capabilities: { illuminate: nil } },
            { uuid: '-1', capabilities: { semaphore: 'green' } }
          ]
        }
        process :create, method: :put, params: params, as: :json
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'has two successful command requests' do
        expect(json['success'].count).to eq(2)
      end

      it 'has three failed command requests' do
        expect(json['failure'].count).to eq(3)
      end

      it 'returns a pending command to success requests' do
        json['success'].each do |success|
          expect(success).to have_key('_id')
          expect(success).to have_key('uuid')
          expect(success).to have_key('capability')
          expect(success).to have_key('created_at')
          expect(success).to have_key('updated_at')
          expect(success).to have_key('value')
          expect(success).to have_key('status')
          expect(success['status']).to eq('pending')
        end
      end

      it 'returns a detailed error description for each failure' do
        json['failure'].each do |failure|
          expect(failure).to have_key('uuid')
          expect(failure).to have_key('capability')
          expect(failure).to have_key('value')

          expect(failure).to have_key('error')
          expect(failure).to have_key('code')
        end
      end

      it 'does not returns a command object for failed requests' do
        json['failure'].each do |failure|
          expect(failure).to_not have_key('_id')
          expect(failure).to_not have_key('status')
          expect(failure).to_not have_key('created_at')
          expect(failure).to_not have_key('updated_at')
        end
      end
    end

    context 'with multiple valid requests' do
      before do
        allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
        params = {
          data: [
            {
              uuid: '1',
              capabilities: { illuminate: 'moderate', semaphore: 'red' }
            },
            {
              uuid: '2',
              capabilities: { illuminate: nil, semaphore: 'red' }
            },
            {
              uuid: '-1',
              capabilities: { semaphore: 'green', illuminate: 'low' }
            }
          ]
        }
        process :create, method: :put, params: params, as: :json
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'has two successful command requests' do
        expect(json['success'].count).to eq(1)
      end

      it 'has four failed command requests' do
        expect(json['failure'].count).to eq(5)
      end

      it 'returns a pending command to success requests' do
        json['success'].each do |success|
          expect(success).to have_key('_id')
          expect(success).to have_key('uuid')
          expect(success).to have_key('capability')
          expect(success).to have_key('created_at')
          expect(success).to have_key('updated_at')
          expect(success).to have_key('value')
          expect(success).to have_key('status')
          expect(success['status']).to eq('pending')
        end
      end

      it 'returns a detailed error description for each failure' do
        json['failure'].each do |failure|
          expect(failure).to have_key('uuid')
          expect(failure).to have_key('capability')
          expect(failure).to have_key('value')

          expect(failure).to have_key('error')
          expect(failure).to have_key('code')
        end
      end

      it 'does not returns a command object for failed requests' do
        json['failure'].each do |failure|
          expect(failure).to_not have_key('_id')
          expect(failure).to_not have_key('status')
          expect(failure).to_not have_key('created_at')
          expect(failure).to_not have_key('updated_at')
        end
      end
    end

    context 'with invalid parameters' do
      it "requires 'data' key" do
        process :create,
                method: :put,
                params: { uuid: '1', capabilities: { semaphore: 'green' } }

        expect(response).to have_http_status(400)
        expect(json).to have_key('error')
      end
    end
  end
end
