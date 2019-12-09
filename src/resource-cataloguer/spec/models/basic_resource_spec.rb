# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BasicResource, type: :model do
  let!(:temperature_sensor) { Capability.new(name: 'temperature', function: Capability.sensor_index) }
  let!(:semaphore_actuator) { Capability.new(name: 'semaphore', function: Capability.actuator_index) }
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

  describe '#to_json?' do
    let!(:resource) do
      described_class.new(
        resource_params.merge(capabilities: [semaphore_actuator, temperature_sensor], uri: 'example2.com')
      )
    end
    context 'when no function is specified' do
      subject { resource.to_json[:capabilities] }
      it { is_expected.to include(semaphore_actuator.name) }
      it { is_expected.to include(temperature_sensor.name) }
    end

    context 'when sensors function is specified' do
      subject { resource.to_json('sensors')[:capabilities] }
      it { is_expected.not_to include(semaphore_actuator.name) }
      it { is_expected.to include(temperature_sensor.name) }
    end

    context 'when actuators function is specified' do
      subject { resource.to_json('actuators')[:capabilities] }
      it { is_expected.to include(semaphore_actuator.name) }
      it { is_expected.not_to include(temperature_sensor.name) }
    end

    context 'when informations function is specified' do
      subject { resource.to_json('informations')[:capabilities] }
      it { is_expected.not_to include(semaphore_actuator.name) }
      it { is_expected.not_to include(temperature_sensor.name) }
    end
  end
end
