# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActuatorCommand, :integration, type: :model do
  context 'publish content after create' do
    subject(:actuator_command) { FactoryGirl.build(:valid_actuator_command) }

    it 'has a "pending" status when published correctly' do
      allow(actuator_command).to receive(:notify_command_request).and_return(true)
      actuator_command.save!
      expect(actuator_command.status).to eq('pending')
    end

    it 'has a "failed" status when not published correctly' do
      allow(actuator_command).to receive(:notify_command_request).and_raise(StandardError)
      actuator_command.save!
      expect(actuator_command.status).to eq('failed')
    end
  end

  describe 'scopes' do
    before do
      allow_any_instance_of(ActuatorCommand).to receive(:notify_command_request).and_return(true)
      FactoryGirl.create(:valid_actuator_command, uuid: '1234', capability: 'semaphore')
      FactoryGirl.create(:processed_actuator_command, uuid: '1234', capability: 'illuminate')
      FactoryGirl.create(:processed_actuator_command, uuid: 'XPTO', capability: 'semaphore')
      FactoryGirl.create(:failed_actuator_command, uuid: 'XPTO', capability: 'semaphore')
      FactoryGirl.create(:rejected_actuator_command, uuid: '1234', capability: 'semaphore')
      FactoryGirl.create(:rejected_actuator_command, uuid: '1234', capability: 'semaphore')
    end

    context 'when apply simple filters' do
      it 'returns 1 pending command' do
        expect(ActuatorCommand.status('pending').count).to eq(1)
      end

      it 'returns 2 processed command' do
        expect(ActuatorCommand.status('processed').count).to eq(2)
      end

      it 'returns 2 rejected command' do
        expect(ActuatorCommand.status('rejected').count).to eq(2)
      end

      it 'returns 4 commands to the resource with uuid 1234' do
        expect(ActuatorCommand.uuid('1234').count).to eq(4)
      end

      it 'returns 2 commands to the resource with uuid 1234' do
        expect(ActuatorCommand.uuid('XPTO').count).to eq(2)
      end

      it 'returns 0 commands to the resource with uuid RANDOM' do
        expect(ActuatorCommand.uuid('RANDOM').count).to eq(0)
      end

      it "returns 5 commands to resources with 'semaphore' capability" do
        expect(ActuatorCommand.capability('semaphore').count).to eq(5)
      end

      it 'returns the most recent commands' do
        commands = ActuatorCommand.recent
        more_recent = nil
        commands.each do |current_command|
          if more_recent.nil?
            more_recent = current_command
            next
          end

          expect(more_recent.created_at).to be >= current_command.created_at
          more_recent = current_command
        end
      end
    end

    context 'when apply complex filters' do
      it 'filters processed commands for resource with uuid 1234' do
        params = { status: 'processed', uuid: '1234' }
        expect(ActuatorCommand.filter(params).count).to eq(1)
      end

      it 'filters semaphore commands for resource with uuid 1234' do
        params = { capability: 'semaphore', uuid: '1234' }
        expect(ActuatorCommand.filter(params).count).to eq(3)
      end

      it 'filters rejectec semaphore commands' do
        params = { capability: 'semaphore', status: 'rejected' }
        expect(ActuatorCommand.filter(params).count).to eq(2)
      end
    end
  end
end
