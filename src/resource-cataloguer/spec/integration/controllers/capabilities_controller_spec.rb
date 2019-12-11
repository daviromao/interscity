# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe CapabilitiesController, :integration, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#create' do
    context 'with valid params for sensor' do
      before :each do
        params = {
          name: 'teste0',
          description: 'zero',
          capability_type: 'sensor'
        }
        post 'create', params: params, format: :json
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq('teste0')
        expect(json['description']).to eq('zero')
        expect(json['capability_type']).to eq('sensor')
        expect(json['id']).to be_truthy
      end

      it 'is expected to create a sensor capability in database' do
        expect(Capability.find_by(name: 'teste0')).to be_truthy
      end
    end

    context 'with valid params for actuator' do
      before :each do
        params = {
          name: 'teste1',
          description: 'one',
          capability_type: 'actuator'
        }
        post 'create', params: params, format: :json
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq('teste1')
        expect(json['description']).to eq('one')
        expect(json['capability_type']).to eq('actuator')
        expect(json['id']).to be_truthy
      end

      it 'is expected to create an actuator capability in database' do
        expect(Capability.find_by(name: 'teste1')).to be_truthy
      end
    end

    context 'with valid params for information' do
      before :each do
        params = {
          name: 'teste2',
          description: 'two',
          capability_type: 'information'
        }
        post 'create', params: params, format: :json
      end

      it 'is expected to respond with attributes' do
        expect(json['name']).to eq('teste2')
        expect(json['description']).to eq('two')
        expect(json['capability_type']).to eq('information')
        expect(json['id']).to be_truthy
      end

      it 'is expected to create an information capability in database' do
        expect(Capability.find_by(name: 'teste2')).to be_truthy
      end
    end

    context 'with invalid params' do
      it 'is expected to reject an invalid capability_type' do
        params = {
          name: 'teste_fail',
          escription: 'some description',
          capability_type: 'invalid'
        }
        post 'create', params: params, format: :json

        expect(response.status).to eq(400)
        expect(json['error']).to eq('Bad capability_type')
        expect(Capability.find_by(name: 'teste_fail')).to be_falsey
      end

      it 'is expected to reject a creation with a duplicate name' do
        Capability.create_sensor(name: 'teste_fail',
                                 description: 'some description')

        post 'create',
             params: {
               name: 'teste_fail',
               description: 'some description',
               capability_type: 'sensor'
             },
             format: :json

        expect(response.status).to eq(400)
        expect(json['error']).to eq('Name has already been taken')
      end

      it 'is expected to reject a creation without name' do
        params = {
          description: 'some description',
          capability_type: 'information'
        }

        post 'create', params: params, format: :json

        expect(response.status).to eq(400)
        expect(json['error']).to eq("Name can't be blank")
      end

      it 'is expected to reject a creation without capability_type' do
        params = {
          name: 'teste_fail',
          description: 'some description'
        }

        post 'create', params: params, format: :json

        expect(response.status).to eq(400)
        expect(json['error']).to eq('Bad capability_type')
        expect(Capability.find_by(name: 'teste_fail')).to be_falsey
      end
    end
  end

  describe '#index' do
    before :each do
      Capability.create_sensor(name: 'Sensor1',
                               description: 'first sensor')
      Capability.create_sensor(name: 'Sensor2',
                               description: 'second sensor')
      Capability.create_sensor(name: 'Sensor3',
                               description: 'third sensor')
      Capability.create_actuator(name: 'Actuator1',
                                 description: 'first actuator')
      Capability.create_actuator(name: 'Actuator2',
                                 description: 'second actuator')
      Capability.create_actuator(name: 'Actuator3',
                                 description: 'third actuator')
      Capability.create_information(name: 'Info1',
                                    description: 'first information')
      Capability.create_information(name: 'Info2',
                                    description: 'second information')
      Capability.create_information(name: 'Info3',
                                    description: 'third information')
    end

    context 'Successful' do
      it 'returns success status' do
        get 'index'
        expect(response.status).to eq(200)
      end

      it 'is expected to find all capabilities' do
        get 'index'
        expect(json['capabilities']).to be_truthy
        expect(json['capabilities'].count).to eq 9
      end

      it 'is expected to find all sensors' do
        get 'index', params: { capability_type: 'sensor' }
        expect(json['capabilities']).to be_truthy
        expect(json['capabilities'].count).to eq 3
      end

      it 'is expected to find all actuators' do
        get 'index', params: { capability_type: 'actuator' }
        expect(json['capabilities']).to be_truthy
        expect(json['capabilities'].count).to eq 3
      end

      it 'is expected to find all information' do
        get 'index', params: { capability_type: 'information' }
        expect(response.status).to eq(200)
        expect(json['capabilities']).to be_truthy
        expect(json['capabilities'].count).to eq 3
      end

      it 'is expected to not find any capability for invalid capability types' do
        get 'index', params: { capability_type: 'informatio' }
        expect(response.status).to eq(200)
        expect(json['capabilities']).to be_truthy
        expect(json['capabilities'].count).to eq 0
      end
    end
  end

  describe '#show' do
    let!(:capabilitySensor) do
      Capability.create_sensor(
        name: 'bus_monitoring',
        description: 'Collects data regarding the operation of the bus such as its location and speed'
      )
    end
    # rubocop:disable Metrics/LineLength
    let!(:capabilityActuator) do
      Capability.create_actuator(
        name: 'semaphore',
        description: 'Collects data regarding the operation of the semaphore such as its current color light and change speed'
      )
    end
    # rubocop:enable Metrics/LineLength
    let!(:capabilityInformation) do
      Capability.create_information(name: 'info_total_capacity',
                                    description: 'Collects dada from a Health Facility regarding its maximum capacity')
    end

    context 'Successful' do
      it 'is expected to find the correct sensor capatility and returns success status' do
        get 'show', params: { name: capabilitySensor.name }, format: :json
        expect(json['name']).to eq capabilitySensor.name
        expect(json['description']).to eq capabilitySensor.description
        expect(response.status).to eq(200)
      end

      it 'is expected to find the correct actuator capatility' do
        get 'show', params: { name: capabilityActuator.name }, format: :json

        expect(json['name']).to eq capabilityActuator.name
        expect(json['description']).to eq capabilityActuator.description
        expect(response.status).to eq(200)
      end

      it 'is expected to find the correct information capatility' do
        get 'show', params: { name: capabilityInformation.name }, format: :json

        expect(json['name']).to eq capabilityInformation.name
        expect(json['description']).to eq capabilityInformation.description
        expect(response.status).to eq(200)
      end
    end
    context 'Unsuccessful' do
      it 'is expected to not find any capability for an invalid name' do
        get 'show', params: { name: 'InvalidName' }, format: :json

        expect(json['error']).to eq 'Capability not found'
        expect(response.status).to eq(404)
      end

      it 'returns error code 500 when an internal error occurs' do
        allow(Capability).to receive(:find_by).and_raise('Internal Error')

        get 'show', params: { name: 'bus_monitoring' }, format: :json

        expect(json['error']).to eq 'Internal Error'
        expect(response.status).to eq(500)
      end
    end
  end

  describe '#update' do
    before :each do
      Capability.create_sensor(name: 'Sensor1',
                               description: 'first sensor')
    end

    context 'Successful' do
      it 'is expected to update a capability description' do
        put 'update',
            params: { name: 'Sensor1', description: 'the best' }, format: :json
        expect(response.status).to eq(202)
        expect(json['name']).to eq('Sensor1')
        expect(json['description']).to eq('the best')
        expect(json['capability_type']).to eq('sensor')
        expect(json['id']).to be_truthy
        expect(Capability.find_by(name: 'Sensor1')).to be_truthy
      end
    end

    context 'Unsuccessful' do
      it 'is expected reject an invalid name' do
        put 'update',
            params: { name: 'Sens', description: 'the best' }, format: :json
        expect(response.status).to eq(404)
        expect(json['error']).to eq('capability not found')
      end
    end
  end

  describe '#destroy' do
    before :each do
      Capability.create_sensor(name: 'Sensor1',
                               description: 'first sensor')
    end

    context 'Successful' do
      it 'is expected to be success' do
        delete 'destroy', params: { name: Capability.last.name }
        expect(response.status).to eq(204)
      end

      it 'is expected to delete a capability on database' do
        expect do
          delete 'destroy', params: { name: Capability.last.name }
        end.to change { Capability.count }.by(-1)
      end
    end

    context 'Unsuccessful' do
      it 'is expected to return an error if an invalid name is passed' do
        delete 'destroy', params: { name: 'fake_name' }
        expect(response.status).to eq(404)
      end

      it 'does not destroy a capability on database' do
        expect do
          delete 'destroy', params: { name: 'fake_name' }
        end.to change { Capability.count }.by(0)
      end
    end
  end
end
