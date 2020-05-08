# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'resource_init with queue parameters' do |*queue_parameters|
  describe 'initialize' do
    before { subject }

    it 'is expected to create a channel' do
      expect(Rails.configuration.worker_conn).to have_received(:create_channel)
    end

    it 'is expected to prefetch the channel' do
      expect(channel).to have_received(:prefetch).with(2)
    end

    it 'is expected to get the channel topic' do
      expect(channel).to have_received(:topic).with(described_class::TOPIC)
    end

    it 'is expected to get the channel queue' do
      expect(channel).to have_received(:queue).with(*queue_parameters)
    end
  end
end

RSpec.shared_examples 'resource_cancel' do
  describe 'cancel' do
    let(:consumer) { double('consumer') }
    let(:consumers) { [consumer] }

    before do
      allow(consumer).to receive(:cancel)
      allow(channel).to receive(:close)

      subject.instance_variable_set('@consumers', consumers)
      subject.cancel
    end

    it 'is expected to cancel the consumers' do
      expect(consumer).to have_received(:cancel)
    end

    it 'is expected to close the channel' do
      expect(channel).to have_received(:close)
    end
  end
end
