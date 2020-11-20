# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe BasicResourcesController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe 'search' do
    context 'with no errors' do
      let(:resources) { 'resources' }

      before do
        expect(subject).to receive_message_chain(:filtered_resources, :paginate).and_return(resources)

        get :search
      end

      it 'is expected to return a json with the resources' do
        expect(json['resources']).to eq(resources)
      end

      it 'is expected to respond with success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with errors' do
      let(:error) { StandardError.new('message') }
      let(:error_message) { "Error while searching resource: #{error.message}" }

      before do
        expect(subject).to receive_message_chain(:filtered_resources, :paginate).and_raise(error)

        get :search
      end

      it 'is expected to return with unprocessable entity code' do
        expect(response).to have_http_status(422)
      end

      it 'is expected to render a json with error' do
        expect(json['error']).to eq(error_message)
      end
    end
  end

  describe 'create' do
    let(:resource) { double('resource') }

    before do
      expect(BasicResource).to receive(:new).and_return(resource)
    end

    context 'when successfully creating a resource' do
      before do
        allow(resource).to receive(:save!)
        allow(subject).to receive(:notify_resource)
        allow(subject).to receive_message_chain(:capability_params, :[], :present?)
          .and_return(true)
        allow(subject).to receive(:add_capabilities_to_resource)

        post :create, params: { data: { capabilities: [], description: 'description' } }
      end

      it 'is expected to return a created status' do
        expect(response).to have_http_status(201)
      end

      it 'is expected to save the new resource' do
        expect(resource).to have_received(:save!)
      end

      it 'is expected to add the capabilities to the resource' do
        expect(subject).to have_received(:add_capabilities_to_resource)
      end

      it 'is expected to notify the creation of resource' do
        expect(subject).to have_received(:notify_resource).with(resource)
      end

      it 'is expected to return a json with the resource' do
        expect(json['data']).to eq(resource.to_json)
      end
    end

    context 'when there is an error' do
      let(:error_message) { 'error message' }

      before do
        allow(resource).to receive(:save!).and_raise(StandardError.new(error_message))

        post :create, params: { data: { capabilities: [], description: 'description' } }
      end

      it 'is expected to return with unprocessable entity code' do
        expect(response).to have_http_status(422)
      end

      it 'is expected to render a json with error' do
        expect(json['error']).to eq(error_message)
      end
    end
  end

  describe 'index' do
    let(:resources) { 'resources' }
    let(:page) { '2' }
    let(:per_page) { '30' }

    before do
      allow(BasicResource).to receive_message_chain(:order, :page, :per_page)
        .and_return(resources)

      get :index, params: { page: page, per_page: per_page }
    end

    it 'is expected to order and paginate the resources' do
      expect(BasicResource).to have_received(:order).with('created_at DESC')
      expect(BasicResource.order).to have_received(:page).with(page)
      expect(BasicResource.order.page).to have_received(:per_page).with(per_page)
    end

    it 'is expected to return a success code' do
      expect(response).to have_http_status(200)
    end

    it 'is expected to return a json with the resources' do
      expect(json['resources']).to eq(resources)
    end
  end

  describe 'index_sensors' do
    let(:resources) { 'resources' }
    let(:page) { '2' }
    let(:per_page) { '30' }

    before do
      allow(BasicResource).to receive_message_chain(:all_sensors, :order, :page, :per_page)
        .and_return(resources)

      get :index_sensors, params: { page: page, per_page: per_page }
    end

    it 'is expected to order and paginate the resources' do
      expect(BasicResource).to have_received(:all_sensors)
      expect(BasicResource.all_sensors).to have_received(:order).with('created_at DESC')
      expect(BasicResource.all_sensors.order).to have_received(:page).with(page)
      expect(BasicResource.all_sensors.order.page).to have_received(:per_page).with(per_page)
    end

    it 'is expected to return a success code' do
      expect(response).to have_http_status(200)
    end

    it 'is expected to return a json with the resources' do
      expect(json['resources']).to eq(resources)
    end
  end

  describe 'index_actuators' do
    let(:resources) { 'resources' }
    let(:page) { '2' }
    let(:per_page) { '30' }

    before do
      allow(BasicResource).to receive_message_chain(:all_actuators, :order, :page, :per_page)
        .and_return(resources)

      get :index_actuators, params: { page: page, per_page: per_page }
    end

    it 'is expected to order and paginate the resources' do
      expect(BasicResource).to have_received(:all_actuators)
      expect(BasicResource.all_actuators).to have_received(:order).with('created_at DESC')
      expect(BasicResource.all_actuators.order).to have_received(:page).with(page)
      expect(BasicResource.all_actuators.order.page).to have_received(:per_page).with(per_page)
    end

    it 'is expected to return a success code' do
      expect(response).to have_http_status(200)
    end

    it 'is expected to return a json with the resources' do
      expect(json['resources']).to eq(resources)
    end
  end

  describe 'show' do
    let(:uuid) { 'uuid' }
    let(:resource) { double('resource') }

    context 'with no errors' do
      before do
        allow(BasicResource).to receive(:find_by!).and_return(resource)

        get :show, params: { uuid: uuid }
      end

      it 'is expected to respond with success' do
        expect(response).to have_http_status(200)
      end

      it 'is expected to return a json with the resource' do
        expect(json['data']).to eq(resource.to_json)
      end
    end

    context 'when the resource is not found' do
      before do
        allow(BasicResource).to receive(:find_by!).and_raise(StandardError)

        get :show, params: { uuid: uuid }
      end

      it 'is expected to respond with not found' do
        expect(response).to have_http_status(404)
      end

      it 'is expected to return a json with an error' do
        expect(json['error']).to eq('Resource not found')
      end
    end
  end

  describe 'update' do
    let(:resource) { double('resource') }
    let(:uuid) { 'uuid' }

    before do
      expect(BasicResource).to receive(:find_by).and_return(resource)
    end

    context 'with no errors' do
      before do
        allow(subject).to receive(:update_resource_and_capabilities)

        put :update, params: { uuid: uuid }
      end

      it 'is expected to update the resource' do
        expect(subject).to have_received(:update_resource_and_capabilities).with(resource)
      end

      it 'is expected to respond with success' do
        expect(response).to have_http_status(200)
      end

      it 'is expected to return a json with the data' do
        expect(json['data']).to eq(resource.to_json)
      end
    end

    context 'with an error' do
      let(:error) { StandardError.new('message') }
      let(:error_message) { "Error while updating basic resource: #{error}" }

      before do
        expect(subject).to receive(:update_resource_and_capabilities).and_raise(error)

        put :update, params: { uuid: uuid }
      end

      it 'is expected to respond with unprocessable entity' do
        expect(response).to have_http_status(422)
      end

      it 'is expected to render an error json' do
        expect(json['error']).to eq(error_message)
      end
    end
  end

  describe 'private' do
    describe 'capability_params' do
      before do
        allow(subject).to receive_message_chain(:params, :require, :permit)

        subject.send(:capability_params)
      end

      it 'is expected to require a data field' do
        expect(subject.params).to have_received(:require).with(:data)
      end

      it 'is expected to require a data field' do
        expect(subject.params.require).to have_received(:permit)
          .with(capabilities: [])
      end
    end

    describe 'filtered_resources' do
      let(:resources) { double('resources') }
      let(:params) { { data: { uuid: 'uuid' } } }

      before do
        expect(BasicResource).to receive(:all).and_return(resources)
        allow(subject).to receive(:params).and_return(double('params', permit: params))

        %i[filter_capabilities filter_position filter_distance filter_resources].each do |filter|
          allow(subject).to receive(filter).and_return(resources)
        end

        @result = subject.send(:filtered_resources)
      end

      it 'is expected to filter by capabilities' do
        expect(subject).to have_received(:filter_capabilities)
      end

      it 'is expected to filter by position' do
        expect(subject).to have_received(:filter_position)
      end

      it 'is expected to filter by distance' do
        expect(subject).to have_received(:filter_distance)
      end

      it 'is expected to filter by resources' do
        expect(subject).to have_received(:filter_resources)
      end

      it 'is expected to return the filtered resources' do
        expect(@result).to eq(resources)
      end
    end

    describe 'add_capabilities_to_resource' do
      let(:capabilities) { ['temperature'] }
      let(:resource) { double('resource', capabilities: double('capabilities')) }
      let(:query) { double('query') }

      before do
        allow(Capability).to receive(:where).and_return(query)
      end

      context 'when the capability cannot be found' do
        before do
          expect(query).to receive(:empty?).and_return(true)
        end

        it 'is expected to raise a CapabilityNotFound error' do
          expect do
            subject.send(:add_capabilities_to_resource, capabilities, resource)
          end.to raise_error(CapabilityNotFound)
        end
      end

      context 'when the capability is found' do
        let(:take) { 'take' }

        it 'is expected to populate the resource with the capabilities' do
          expect(query).to receive(:empty?).and_return(false)
          expect(query).to receive(:take).and_return(take)
          expect(resource.capabilities).to receive(:<<).with(take)

          subject.send(:add_capabilities_to_resource, capabilities, resource)
        end
      end
    end

    describe 'update_resource_and_capabilities' do
      let(:resource) { double('resource') }
      let(:capability_param) { double('capability_param', present?: true) }

      before do
        allow(subject).to receive(:component_params).and_return([])
        allow(resource).to receive(:update!)
        allow(subject).to receive_message_chain(:capability_params, :[]).and_return(capability_param)
        allow(resource).to receive_message_chain(:capabilities, :destroy_all)
        allow(subject).to receive(:add_capabilities_to_resource)
        allow(subject).to receive(:notify_resource)

        subject.send(:update_resource_and_capabilities, resource)
      end

      it 'is expected to update the resource' do
        expect(resource).to have_received(:update!)
      end

      it 'is expected to delete the current resource capabilities' do
        expect(resource.capabilities).to have_received(:destroy_all)
      end

      it 'is expected to add the capabilities to the resource' do
        expect(subject).to have_received(:add_capabilities_to_resource).with(capability_param, resource)
      end

      it 'is expected to notify the resource change' do
        expect(subject).to have_received(:notify_resource).with(resource, {}, true)
      end
    end
  end
end
