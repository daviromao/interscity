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

  describe 'private methods' do
    subject(:actuator_command) { FactoryGirl.build(:valid_actuator_command) }

    describe 'publish_command' do
      context 'successful notification' do
        before do
          allow(subject).to receive(:notify_command_request)

          subject.send(:publish_command)
        end

        it 'is expected to notify command request' do
          expect(subject).to have_received(:notify_command_request)
        end
      end

      context 'failed notification' do
        before do
          allow(subject).to receive(:notify_command_request) { raise StandardError }
          allow(subject).to receive(:save)

          subject.send(:publish_command)
        end

        it 'is expected to update the status' do
          expect(subject).to have_received(:save)
          expect(subject.status).to eq('failed')
        end
      end
    end
  end
end
