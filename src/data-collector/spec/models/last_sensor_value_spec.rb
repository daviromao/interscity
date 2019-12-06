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

    uuid_pattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    expect(uuid_pattern.match(uuid)).not_to be_nil
  end

  it 'has a value' do
    expect(sensor_value_default.value).not_to be_nil
    expect(sensor_value_default.value).not_to eq('')

    expect(FactoryGirl.build(:last_sensor_value, value: ' ')).not_to be_valid
    expect(FactoryGirl.build(:last_sensor_value, value: nil)).not_to be_valid
  end
end
