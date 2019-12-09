# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BasicResource, type: :model do
  let!(:temperature_sensor) { Capability.new(name: 'temperature', function: Capability.sensor_index) }
  let!(:semaphore_actuator) { Capability.new(name: 'semaphore', function: Capability.actuator_index) }
  let!(:parking_information) { Capability.new(name: 'parking slot', function: Capability.information_index) }
  let(:resource_params) do
    {
      description: 'just a resource',
      lat: 10,
      lon: 10,
      status: 'stopped',
      collect_interval: 5,
      uri: 'example.com'
    }
  end

  describe '#create' do
    let(:resource) { described_class.create(resource_params) }
    it 'automatically creates an uuid' do
      expect(resource.uuid).to_not be_nil
    end

    context 'when the uuid is created by the client' do
      it 'saves when the uuid is valid' do
        new_resource = described_class.new(
          resource_params.merge(uuid: '2d931510-d99f-494a-8c67-87feb05e1594')
        )
        expect { new_resource.save! }.to change { BasicResource.count }.by(1)

        new_resource.reload
        expect(new_resource.uuid).to eq('2d931510-d99f-494a-8c67-87feb05e1594')
      end

      it 'does not save when the uuid is invalid - not compatible with RFC 4122' do
        new_resource = described_class.new(
          resource_params.merge(uuid: 'Not A Valid UUID')
        )
        expect { new_resource.save }.to change { BasicResource.count }.by(0)
      end

      it 'should not save when the uuid is not unique' do
        new_resource = described_class.new(resource_params.merge(uuid: resource.uuid))
        expect { new_resource.save }.to change { BasicResource.count }.by(0)
        expect(new_resource.errors.full_messages).to include('Uuid has already been taken')
      end
    end
  end

  describe '.all_sensors' do
    context 'there are no sensors' do
      subject { described_class.all_sensors }
      it { is_expected.to be_empty }
    end

    context 'there is one sensor and one actuator' do
      let!(:sensor) do
        described_class.create(resource_params.merge(capabilities: [temperature_sensor], uri: 'example1.com'))
      end
      let!(:actuator) do
        described_class.create(resource_params.merge(capabilities: [semaphore_actuator], uri: 'example2.com'))
      end
      subject { described_class.all_sensors }
      it { is_expected.to include(sensor) }
      it { is_expected.not_to include(actuator) }
    end

    context 'there is a hybrid sensor-actuator' do
      let!(:hybrid) do
        described_class.create(resource_params.merge(capabilities: [temperature_sensor, semaphore_actuator]))
      end
      subject { described_class.all_sensors }
      it { is_expected.to include(hybrid) }
    end
  end

  describe '.all_actuators' do
    context 'there are no actuators' do
      subject { described_class.all_actuators }
      it { is_expected.to be_empty }
    end

    context 'there is one actuator and one information' do
      let!(:actuator) do
        described_class.create(resource_params.merge(capabilities: [semaphore_actuator], uri: 'example2.com'))
      end
      let!(:information) do
        described_class.create(resource_params.merge(capabilities: [parking_information], uri: 'example3.com'))
      end
      subject { described_class.all_actuators }
      it { is_expected.to include(actuator) }
      it { is_expected.not_to include(information) }
    end

    context 'there is a hybrid sensor-actuator' do
      let!(:hybrid) do
        described_class.create(resource_params.merge(capabilities: [parking_information, semaphore_actuator]))
      end
      subject { described_class.all_actuators }
      it { is_expected.to include(hybrid) }
    end
  end

  describe '#sensor?' do
    let!(:actuator) do
      described_class.create(resource_params.merge(capabilities: [semaphore_actuator], uri: 'example2.com'))
    end
    let!(:sensor) do
      described_class.create(resource_params.merge(capabilities: [temperature_sensor], uri: 'example1.com'))
    end
    context 'resource is a sensor' do
      subject { sensor.sensor? }
      it { is_expected.to eq(true) }
    end

    context 'resource is an actuator' do
      subject { actuator.actuator? }
      it { is_expected.to eq(true) }
    end
  end

  describe 'cache-related methods' do
    context 'resource with capabilities' do
      let!(:resource) do
        described_class.create(
          resource_params.merge(capabilities: [semaphore_actuator, temperature_sensor], uri: 'example2.com')
        )
      end

      it 'returns the name of all capabilities' do
        expect(resource.capability_names).to include(semaphore_actuator.name)
        expect(resource.capability_names).to include(temperature_sensor.name)
      end

      it 'does not cache capability names before first call' do
        expect(resource.get_cached_capabilities).to be_blank
        expect(resource.get_cached_capabilities('sensors')).to be_blank
        expect(resource.get_cached_capabilities('actuators')).to be_blank
      end

      it 'caches capability names after first call' do
        resource.capability_names
        expect(resource.get_cached_capabilities).to include(temperature_sensor.name)
        expect(resource.get_cached_capabilities).to include(semaphore_actuator.name)

        resource.capability_names('sensors')
        expect(resource.get_cached_capabilities('sensors')).to include(temperature_sensor.name)
        resource.capability_names('actuators')
        expect(resource.get_cached_capabilities('actuators')).to include(semaphore_actuator.name)
      end
    end

    context 'resource without capabilities' do
      let!(:resource) { described_class.create(resource_params) }

      it 'returns an empty array when call capability_names' do
        expect(resource.capability_names).to be_blank
      end

      it 'does not cache anything before call capability_names' do
        expect(resource.get_cached_capabilities).to be_blank
        expect(resource.get_cached_capabilities('sensors')).to be_blank
        expect(resource.get_cached_capabilities('actuators')).to be_blank
      end

      it 'does not cache anything after call capability_names' do
        resource.capability_names
        expect(resource.get_cached_capabilities).to be_blank

        resource.capability_names('sensors')
        expect(resource.get_cached_capabilities('sensors')).to be_blank

        resource.capability_names('actuators')
        expect(resource.get_cached_capabilities('actuators')).to be_blank
      end

      context "change resources' capabilities" do
        it 'updates cache when adding a new sensor capability' do
          resource.capabilities << temperature_sensor
          expect(resource.get_cached_capabilities).to include(temperature_sensor.name)
          expect(resource.get_cached_capabilities('sensors')).to include(temperature_sensor.name)
        end

        it 'updates cache when adding a new actuator capability' do
          resource.capabilities << semaphore_actuator
          expect(resource.get_cached_capabilities).to include(semaphore_actuator.name)
          expect(resource.get_cached_capabilities('actuators')).to include(semaphore_actuator.name)
        end

        it 'updates cache when removing a new sensor capability' do
          resource.capabilities << temperature_sensor
          resource.capabilities.delete(temperature_sensor)
          expect(resource.get_cached_capabilities).to_not include(temperature_sensor.name)
          expect(resource.get_cached_capabilities('sensors')).to_not include(temperature_sensor.name)
        end

        it 'updates cache when removing a new actuator capability' do
          resource.capabilities << semaphore_actuator
          resource.capabilities.delete(semaphore_actuator)
          expect(resource.get_cached_capabilities).to_not include(semaphore_actuator.name)
          expect(resource.get_cached_capabilities('actuators')).to_not include(semaphore_actuator.name)
        end
      end
    end
  end
end
