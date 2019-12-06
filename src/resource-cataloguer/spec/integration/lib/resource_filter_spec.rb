# frozen_string_literal: true

# inspired by http://stackoverflow.com/questions/8430719/how-to-write-run-specs-for-files-other-than-model-view-controller
require 'rails_helper'
require 'spec_helper'
require Rails.root.join('lib', 'resource_filter.rb')

describe SmartCities::ResourceFilter do
  let(:filter) do
    class Filter
      include SmartCities::ResourceFilter
    end
    Filter.new
  end
  let(:temperature_sensor) { Capability.new(name: 'temperature', function: Capability.sensor_index) }
  let(:semaphore_actuator) { Capability.new(name: 'semaphore', function: Capability.actuator_index) }
  let(:parking_information) { Capability.new(name: 'parking slot', function: Capability.information_index) }
  let!(:resource1) do
    BasicResource.create(
      description: 'just a resource',
      lat: -23.559616,
      lon: -46.731386,
      status: 'stopped',
      collect_interval: 5,
      uri: 'example.com',
      capabilities: [semaphore_actuator]
    )
  end
  let!(:resource2) do
    BasicResource.create(
      description: 'just another resource',
      lat: -23,
      lon: -46,
      status: 'live',
      collect_interval: 20,
      uri: 'saojose.com',
      capabilities: [temperature_sensor]
    )
  end
  let!(:resource3) do
    BasicResource.create(
      description: 'just another another resource',
      lat: -42,
      lon: -15,
      status: 'live',
      collect_interval: 1,
      uri: 'nowhere.com',
      capabilities: [parking_information]
    )
  end
  let!(:resources) do
    BasicResource.all
  end

  describe '#filter_resources' do
    context "search by 'stopped' status" do
      subject { filter.filter_resources resources, :status, 'stopped' }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search by 'live' status" do
      subject { filter.filter_resources resources, :status, 'live' }
      it { is_expected.not_to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
    context 'search by postal code' do
      subject { filter.filter_resources resources, :postal_code, resource1.postal_code }
      it { is_expected.to include(resource1) }
      xit { is_expected.not_to include(resource2) }
      xit { is_expected.not_to include(resource3) }
    end
    context 'search by neighborhood' do
      subject { filter.filter_resources resources, :neighborhood, 'Butantã' }
      xit { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'search by city' do
      subject { filter.filter_resources resources, :city, 'São José dos Campos' }
      it { is_expected.not_to include(resource1) }
      xit { is_expected.to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
  end

  describe '#filter_capabilities' do
    context "search for 'temperature' capability" do
      subject { filter.filter_capabilities resources, capability: :temperature }
      it { is_expected.not_to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'search for no capabilities' do
      subject { filter.filter_capabilities resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end

  describe '#filter_position' do
    context 'succesful search by position' do
      subject { filter.filter_position resources, lat: -23.559616, lon: -46.731386 }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'unsuccesful search by position' do
      subject { filter.filter_position resources, lat: 10, lon: 10 }
      it { is_expected.not_to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'search for no position' do
      subject { filter.filter_position resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end

  describe '#filter_distance' do
    context 'succesful search by distance' do
      subject { filter.filter_distance resources, lat: -23.55961, lon: -46.731386, radius: 5 }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'unsuccesful search by distance' do
      subject { filter.filter_distance resources, lat: 10, lon: 10, radius: 5 }
      it { is_expected.not_to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context 'search for no distance' do
      subject { filter.filter_distance resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end
end
