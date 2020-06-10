# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'filter by capability type' do |method, index|
  describe method.to_s do
    before do
      allow(described_class).to receive_message_chain(:joins, :where)

      described_class.send(method)
    end

    it 'is expected to join with capabilities' do
      expect(described_class).to have_received(:joins).with(:capabilities)
    end

    it 'is expected to filter resource by sensor feature' do
      expect(described_class.joins).to have_received(:where)
        .with('capabilities.function' => index)
    end
  end
end

RSpec.shared_examples 'check capability type' do |method, function|
  describe method.to_s do
    before do
      allow(subject).to receive_message_chain(:capabilities, :where, :exists?)
      subject.send(method)
    end

    it 'is expected to check if there is a sensor among the capabilities' do
      expect(subject.capabilities).to have_received(:where).with(function: function)
      expect(subject.capabilities.where).to have_received(:exists?)
    end
  end
end

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

  include_examples 'filter by capability type', :all_sensors, Capability.sensor_index
  include_examples 'filter by capability type', :all_actuators, Capability.actuator_index
  include_examples 'filter by capability type', :all_informations, Capability.information_index

  include_examples 'check capability type', :sensor?, Capability.sensor_index
  include_examples 'check capability type', :actuator?, Capability.actuator_index

  describe 'capability_names' do
    let(:names) { %w[temperature pressure] }

    context 'with cached capabilities' do
      before do
        allow(subject).to receive(:get_cached_capabilities).and_return(names)
        @result = subject.capability_names
      end

      it 'is expected to check if there are cached capabilities' do
        expect(subject).to have_received(:get_cached_capabilities)
      end

      it 'is expected to return the cached names' do
        expect(@result).to eq(names)
      end
    end

    context 'with no cached names' do
      let(:cache) { '' }
      let(:capabilities) { double('capabilities') }

      before do
        allow(subject).to receive(:get_cached_capabilities).and_return(cache)
        allow(subject).to receive(:capabilities).and_return(capabilities)
        allow(capabilities).to receive(:exists?).and_return(true)
        allow(capabilities).to receive(:pluck).and_return(names)
        allow(subject).to receive(:set_cached_capabilities)

        @result = subject.capability_names
      end

      it 'is expected to get the capabilities' do
        expect(subject).to have_received(:capabilities).twice
      end

      it 'is expected to extract the names from the capabilities' do
        expect(capabilities).to have_received(:pluck).with(:name)
      end

      it 'is expected to add the names to the cache' do
        expect(subject).to have_received(:set_cached_capabilities).with(names, nil)
      end

      it 'is expected to return the names' do
        expect(@result).to eq(names)
      end
    end
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

  describe 'as_json' do
    let(:options) { { options: 'options' } }
    let(:names) { %w[temperature pressure] }
    let(:result) { {} }

    before do
      allow(subject).to receive(:capability_names).and_return(names)

      @result = subject.as_json(options)
    end

    it 'is expected to retrieve the capability names' do
      expect(subject).to have_received(:capability_names)
    end

    it 'is expected to return a hash with a modified capabilities field' do
      expect(@result[:capabilities]).to eq(names)
    end
  end

  # TODO: Find some way to mock the `reverse_geocoded_by` call
  # describe 'reverse_geocoded_by' do
  #   before do
  #     allow(described_class).to receive(:reverse_geocoded_by)
  #     subject
  #   end

  #   it 'is expected to configure reverse geocoding' do
  #     expect(subject).to have_received(:reverse_geocoded_by)
  #   end
  # end

  describe 'get_cached_capabilities' do
    let(:cached) { 'cached' }
    let(:function) { 'function' }
    let(:uuid) { 'uuid' }

    before do
      allow(Rails).to receive_message_chain(:configuration, :redis, :smembers).and_return(cached)
      expect(subject).to receive(:uuid).and_return(uuid)

      @result = subject.get_cached_capabilities(function)
    end

    it 'is expected to look for a cached result on redis' do
      expect(Rails.configuration.redis).to have_received(:smembers).with("#{uuid}:#{function}")
    end

    it 'is expected to return the cached results' do
      expect(@result).to eq(cached)
    end
  end

  describe 'set_cached_capabilities' do
    let(:names) { %w[temperature pressure] }
    let(:uuid) { 'uuid' }
    let(:function) { 'function' }

    before do
      allow(Rails).to receive_message_chain(:configuration, :redis, :sadd)
      expect(subject).to receive(:uuid).and_return(uuid)

      subject.set_cached_capabilities(names, function)
    end

    it 'is expected to cache the names' do
      expect(Rails.configuration.redis).to have_received(:sadd).with("#{uuid}:#{function}", names)
    end
  end

  describe 'remove_cached_capabilities' do
    let(:names) { %w[temperature pressure] }
    let(:uuid) { 'uuid' }
    let(:function) { 'function' }

    before do
      allow(Rails).to receive_message_chain(:configuration, :redis, :srem)
      expect(subject).to receive(:uuid).and_return(uuid)

      subject.remove_cached_capabilities(names, function)
    end

    it 'is expected to remove the cache' do
      expect(Rails.configuration.redis).to have_received(:srem).with("#{uuid}:#{function}", names)
    end
  end

  describe 'create_uuid' do
    let(:uuid) { 'uuid' }

    context 'when no uuid exists' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
        expect(subject).to receive_message_chain(:uuid, :blank?).and_return(true)

        subject.send(:create_uuid)
      end

      it 'is expected to create a uuid' do
        expect(SecureRandom).to have_received(:uuid)
      end
    end

    context 'when the uuid already exists' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
        expect(subject).to receive_message_chain(:uuid, :blank?).and_return(false)

        subject.send(:create_uuid)
      end

      it 'is expected not to create a new uuid' do
        expect(SecureRandom).not_to have_received(:uuid)
      end
    end
  end

  describe 'uuid_format' do
    let(:uuid) { 'uuid' }

    context 'when the uuid is invalid' do
      before do
        allow(subject).to receive_message_chain(:errors, :add).and_return(uuid)
        expect(subject).to receive(:uuid).and_return(uuid)
        expect(UUID).to receive(:validate).and_return(false)

        subject.send(:uuid_format)
      end

      it 'is expected to add an error' do
        expect(subject.errors).to have_received(:add).with(:uuid, 'is not compatible with RFC 4122')
      end
    end

    context 'when the uuid is valid' do
      before do
        allow(subject).to receive_message_chain(:errors, :add).and_return(uuid)
        expect(subject).to receive(:uuid).and_return(uuid)
        expect(UUID).to receive(:validate).and_return(true)

        subject.send(:uuid_format)
      end

      it 'is expected to add an error' do
        expect(subject.errors).not_to have_received(:add)
      end
    end
  end

  describe 'add_cache' do
    %i[sensor? actuator?].each do |type|
      context "with #{type} capability" do
        let(:capability) { double('capability', name: 'a', sensor?: false, actuator?: false, type => true) }

        before do
          allow(subject).to receive(:set_cached_capabilities)

          subject.send(:add_cache, capability)
        end

        it 'is expected to set the cache' do
          expect(subject).to have_received(:set_cached_capabilities).with(capability.name)
          expect(subject).to have_received(:set_cached_capabilities)
            .with(capability.name, type.to_s.sub('?', 's'))
        end
      end
    end
  end

  describe 'remove_cache' do
    %i[sensor? actuator?].each do |type|
      context "with #{type} capability" do
        let(:capability) do
          double('capability', name: 'a', sensor?: false, actuator?: false, type => true)
        end

        before do
          allow(subject).to receive(:remove_cached_capabilities)

          subject.send(:remove_cache, capability)
        end

        it 'is expected to set the cache' do
          expect(subject).to have_received(:remove_cached_capabilities).with(capability.name)
          expect(subject).to have_received(:remove_cached_capabilities)
            .with(capability.name, type.to_s.sub('?', 's'))
        end
      end
    end
  end
end
