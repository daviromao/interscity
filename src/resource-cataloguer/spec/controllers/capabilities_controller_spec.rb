# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe CapabilitiesController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#create' do
    let(:name) { 'teste0' }
    let(:description) { 'zero' }
    let(:function) { Capability.sensor_index }
    let(:sensor_capability) do
      Capability.new(
        name: name,
        description: description,
        function: function
      )
    end

    context 'with valid params for sensor' do
      before :each do
        allow(Capability).to receive(:create_with_function).and_return(sensor_capability)
        allow(sensor_capability).to receive(:valid?).and_return(true)
        params = {
          name: name,
          description: description,
          capability_type: 'sensor'
        }
        post 'create', params: params, format: :json
      end

      it 'returns a success response' do
        expect(response.status).to eq(201)
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq(name)
        expect(json['description']).to eq(description)
        expect(json['capability_type']).to eq('sensor')
      end
    end

    context 'with valid params for actuator' do
      let(:function) { Capability.actuator_index }
      before :each do
        allow(Capability).to receive(:create_with_function).and_return(sensor_capability)
        allow(sensor_capability).to receive(:valid?).and_return(true)
        params = {
          name: 'teste1',
          description: 'one',
          capability_type: 'actuator'
        }
        post 'create', params: params, format: :json
      end

      it 'returns a success response' do
        expect(response.status).to eq(201)
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq(name)
        expect(json['description']).to eq(description)
        expect(json['capability_type']).to eq('actuator')
      end
    end

    context 'with valid params for information' do
      let(:function) { Capability.information_index }
      before :each do
        allow(Capability).to receive(:create_with_function).and_return(sensor_capability)
        allow(sensor_capability).to receive(:valid?).and_return(true)
        params = {
          name: name,
          description: description,
          capability_type: 'information'
        }
        post 'create', params: params, format: :json
      end

      it 'returns a success response' do
        expect(response.status).to eq(201)
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq(name)
        expect(json['description']).to eq(description)
        expect(json['capability_type']).to eq('information')
      end
    end
  end
end
