# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LastSensorValue, type: :model do
  let(:sensor_value_default) { build(:default_last_value) }

  it 'has a valid factory' do
    expect(sensor_value_default).to be_valid
  end

  it 'has a date of occurence' do
    expect(sensor_value_default.date).not_to be_nil
    expect(sensor_value_default.date).not_to eq('')

    expect(FactoryGirl.build(:last_sensor_value, date: '')).not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, date: nil)).not_to be_valid
  end

  it 'belongs to a resource in the platform' do
    expect(sensor_value_default.uuid).to_not be_nil

    expect(FactoryGirl.build(:last_sensor_value, uuid: ''))
      .not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, uuid: nil))
      .not_to be_valid
  end

  it 'has a capability type' do
    expect(sensor_value_default.capability).to_not be_nil

    expect(FactoryGirl.build(:last_sensor_value, capability: '')).not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, capability: nil))
      .not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, capability: nil)).not_to be_valid
  end

  it 'has a valid resource id' do
    uuid = sensor_value_default.uuid
    expect(uuid).not_to eq('')

    uuid_pattern = /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
    expect(uuid_pattern.match(uuid)).not_to be_nil
  end

  it 'has a value' do
    expect(sensor_value_default.value).not_to be_nil
    expect(sensor_value_default.value).not_to eq('')

    expect(FactoryGirl.build(:last_sensor_value, value: ' ')).not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, value: nil)).not_to be_valid
  end

  describe 'static_attributes' do
    it 'is expected to be a class method' do
      expect(described_class).to respond_to(:static_attributes)
    end

    it 'is expected to have a list of static attributes' do
      expect(described_class.static_attributes).to be_a(Array)
    end
  end

  describe 'dynamic_attributes' do
    before do
      allow(SensorValue).to receive(:static_attributes).and_return(['a'])
      allow(subject.attributes).to receive(:except)

      subject.dynamic_attributes
    end

    it 'is expected to get all filters except the static ones from SensorValue' do
      expect(SensorValue).to have_received(:static_attributes)
      expect(subject.attributes).to have_received(:except).with('a')
    end
  end
end
