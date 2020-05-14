# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SensorValue, type: :model do
  let(:sensor_value_default) { build(:default_sensor_value) }

  it 'has a valid factory' do
    expect(sensor_value_default).to be_valid
  end

  it 'has a date of occurence' do
    expect(sensor_value_default.date).not_to be_nil
    expect(sensor_value_default.date).not_to eq('')
    expect(FactoryGirl.build(:sensor_value, date: '')).not_to be_valid
    expect(FactoryGirl.build(:sensor_value, date: nil)).not_to be_valid
  end

  it 'belongs to a resource in the platform' do
    expect(sensor_value_default.platform_resource).to_not be_nil
    expect(sensor_value_default.platform_resource.uuid).to_not be_nil

    expect(FactoryGirl.build(:sensor_value, platform_resource_id: ''))
      .not_to be_valid
    expect(FactoryGirl.build(:sensor_value, platform_resource_id: nil))
      .not_to be_valid
    expect(FactoryGirl.build(:sensor_value, platform_resource: nil))
      .not_to be_valid
  end

  it 'has a capability type' do
    expect(sensor_value_default.capability).to_not be_nil

    expect(FactoryGirl.build(:sensor_value, capability: '')).not_to be_valid
    expect(FactoryGirl.build(:sensor_value, capability: nil))
      .not_to be_valid
    expect(FactoryGirl.build(:sensor_value, capability: nil)).not_to be_valid
  end

  it 'has a valid resource id' do
    uuid = sensor_value_default.platform_resource.uuid
    expect(uuid).not_to eq('')

    uuid_pattern = /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
    expect(uuid_pattern.match(uuid)).not_to be_nil
  end

  it 'has temperature' do
    expect(sensor_value_default.temperature).not_to be_nil
    expect(sensor_value_default.temperature).not_to eq('')

    expect(FactoryGirl.build(:sensor_value, temperature: '')).not_to be_valid
    expect(FactoryGirl.build(:sensor_value, temperature: nil)).not_to be_valid
  end

  it 'has pressure' do
    expect(sensor_value_default.pressure).not_to be_nil
    expect(sensor_value_default.pressure).not_to eq('')

    expect(FactoryGirl.build(:sensor_value, pressure: '')).not_to be_valid
    expect(FactoryGirl.build(:sensor_value, pressure: nil)).not_to be_valid
  end

  describe 'instance methods' do
    describe 'dynamic_attributes' do
      let(:static_attributes) { ['a'] }

      before do
        allow(described_class).to receive(:static_attributes)
          .and_return(static_attributes)
        allow(subject.attributes).to receive(:except)

        subject.dynamic_attributes
      end

      it 'is expected to get all filters except the static ones from SensorValue' do
        expect(described_class).to have_received(:static_attributes)
        expect(subject.attributes).to have_received(:except).with(*static_attributes)
      end
    end
  end

  describe 'class methods' do
    describe 'static_attributes' do
      it 'is expected to be a class method' do
        expect(described_class).to respond_to(:static_attributes)
      end

      it 'is expected to have a list of static attributes' do
        expect(described_class.static_attributes).to be_a(Array)
      end
    end
  end

  describe 'private methods' do
    describe 'save_last_value' do
      let(:last_sensor_value) { instance_double('LastSensorValue') }
      let(:attributes) { { a: 1 } }

      before do
        allow(LastSensorValue).to receive(:find_or_create_by)
          .and_return(last_sensor_value)
        allow(last_sensor_value).to receive(:save!)
        allow(last_sensor_value).to receive(:process_attribute)

        expect(subject).to receive(:dynamic_attributes)
          .and_return(attributes)

        subject.send(:save_last_value)
      end

      it 'is expected to get the last sensor value' do
        expect(LastSensorValue).to have_received(:find_or_create_by).with(
          uuid: subject.uuid,
          capability: subject.capability
        )
      end

      it 'is expected to process new attributes' do
        expect(last_sensor_value).to have_received(:process_attribute).with(:a, 1)
      end

      it 'is expected to save the last sensor value' do
        expect(last_sensor_value).to have_received(:save!)
      end
    end

    describe 'parse_to_float' do
      let(:key) { 'a' }
      let(:value) { instance_double('String') }
      let(:attributes) { { key => value } }

      before do
        expect(subject).to receive(:attributes).and_return(attributes)

        allow(subject).to receive(:[]=)
        allow(value).to receive(:try).and_return(true)
        allow(value).to receive(:to_f)

        subject.send(:parse_to_float)
      end

      it 'is expected to check if the value looks like a float' do
        expect(value).to have_received(:try).with(:float?)
      end

      it 'is expected to convert the value to float' do
        expect(value).to have_received(:to_f)
      end

      it 'is expected to set the subject attribute with the float' do
        expect(subject).to have_received(:[]=).with(key.to_sym, nil)
      end
    end

    describe 'set_uuid' do
      let(:uuid) { 'uuid' }

      before do
        allow(subject).to receive(:uuid=)
        allow(subject).to receive_message_chain(:platform_resource, :uuid)
          .and_return(uuid)

        subject.send(:set_uuid)
      end

      it 'is expected to get the platform resource uuid' do
        expect(subject.platform_resource).to have_received(:uuid)
      end

      it "is expected to set the objects's uuid" do
        expect(subject).to have_received(:uuid=).with(uuid)
      end
    end
  end
end
