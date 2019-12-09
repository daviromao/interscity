# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActuatorCommand, type: :model do
  context 'with valid attributes' do
    subject(:actuator_command) { FactoryGirl.build(:valid_actuator_command) }

    it { is_expected.to be_valid }
    it 'cannot update status to nil' do
      actuator_command.status = nil
      expect(actuator_command).not_to be_valid
      expect(actuator_command.errors[:status].size).to eq(2)
    end

    it 'cannot update status to a random value' do
      actuator_command.status = 'not_allowed'
      expect(actuator_command).not_to be_valid
      expect(actuator_command.errors[:status].size).to eq(1)
    end
  end

  context 'with missing attributes' do
    subject(:actuator_command) { FactoryGirl.build(:actuator_command_with_missing_attributes) }

    it { is_expected.not_to be_valid }

    it 'validates presence of uuid' do
      actuator_command.valid?
      expect(actuator_command.errors[:uuid].size).to eq(1)
    end

    it 'validates presence of value' do
      actuator_command.valid?
      expect(actuator_command.errors[:value].size).to eq(1)
    end

    it 'validates presence of capability' do
      actuator_command.valid?
      expect(actuator_command.errors[:capability].size).to eq(1)
    end
  end
end
