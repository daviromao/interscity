# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SensorValue, type: :model do
  let(:sensor_value_default) { create(:default_sensor_value) }

  it "stores its resources' uuid" do
    expect(sensor_value_default.uuid).to_not be_nil
    expect(sensor_value_default.uuid).to eq(sensor_value_default.platform_resource.uuid)
  end

  it 'creates a new last sensor value' do
    expect { sensor_value_default }.to change { LastSensorValue.count }.by(1)
  end

  it 'updates an existing last sensor temperature' do
    sensor_value = FactoryGirl.create(:default_sensor_value, temperature: '10')

    last_value_before = LastSensorValue.find_by(
      capability: sensor_value.capability,
      uuid: sensor_value.uuid
    )

    expect(last_value_before.temperature).to eq(10)
    expect { FactoryGirl.create(:default_sensor_value, temperature: '15') }.not_to(change { LastSensorValue.count })

    last_value_after = LastSensorValue.find_by(
      capability: sensor_value.capability,
      uuid: sensor_value.uuid
    )

    expect(last_value_after.temperature).to eq(15)
  end

  it 'updates an existing last sensor pressure' do
    sensor_value = FactoryGirl.create(:default_sensor_value, pressure: '3')

    last_value_before = LastSensorValue.find_by(
      capability: sensor_value.capability,
      uuid: sensor_value.uuid
    )

    expect(last_value_before.pressure).to eq(3)
    expect { FactoryGirl.create(:default_sensor_value, pressure: '5.2') }.not_to(change { LastSensorValue.count })

    last_value_after = LastSensorValue.find_by(
      capability: sensor_value.capability,
      uuid: sensor_value.uuid
    )

    expect(last_value_after.pressure).to eq(5.2)
  end
end
