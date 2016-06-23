# inspired by http://stackoverflow.com/questions/8430719/how-to-write-run-specs-for-files-other-than-model-view-controller
require 'rails_helper'
require 'spec_helper'
require "#{Rails.root}/lib/resource_filter.rb"

describe SmartCities::ResourceFilter do

  let(:filter){
    class Filter
      include SmartCities::ResourceFilter
    end
    Filter.new
  }
  let(:temperature_sensor) { Capability.create(name: "temperature", function: Capability.sensor_index) }
  let(:semaphore_actuator) { Capability.create(name: "semaphore", function: Capability.actuator_index) }
  let(:parking_information) { Capability.create(name: "parking slot", function: Capability.information_index) }
  let!(:resource1) {
    BasicResource.create(
      description: "just a resource",
      lat: -23.559616,
      lon: -46.731386,
      status: "stopped",
      collect_interval: 5,
      uri: "example.com",
      capabilities: [semaphore_actuator]
    )
  }
  let!(:resource2) {
    BasicResource.create(
      description: "just another resource",
      lat: -23,
      lon: -46,
      status: "live",
      collect_interval: 20,
      uri: "saojose.com",
      capabilities: [temperature_sensor]
    )
  }
  let!(:resource3) {
    BasicResource.create(
      description: "just another another resource",
      lat: -42,
      lon: -15,
      status: "live",
      collect_interval: 1,
      uri: "nowhere.com",
      capabilities: [parking_information]
    )
  }
  let!(:resources) {
    BasicResource.all
  }

  describe '#filter_resources' do
    context "search by 'stopped' status" do
      subject { filter.filter_resources resources, :status, "stopped" }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search by 'live' status" do
      subject { filter.filter_resources resources, :status, "live" }
      it { is_expected.not_to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
    context "search by postal code" do
      subject { filter.filter_resources resources, :postal_code, "05508-090" }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search by neighborhood" do
      subject { filter.filter_resources resources, :neighborhood, "Butantã" }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search by city" do
      subject { filter.filter_resources resources, :city, "São José dos Campos" }
      it { is_expected.not_to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
  end

  describe '#filter_capabilities' do
    context "search for 'temperature' capability" do
      subject { filter.filter_capabilities resources, {capability: :temperature} }
      it { is_expected.not_to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search for no capabilities" do
      subject { filter.filter_capabilities resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end

  describe '#filter_position' do
    context "succesful search by position" do
      subject { filter.filter_position resources, { lat: -23.559616, lon: -46.731386 } }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "unsuccesful search by position" do
      subject { filter.filter_position resources, { lat: 10, lon: 10 } }
      it { is_expected.not_to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search for no position" do
      subject { filter.filter_position resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end

  describe '#filter_distance' do
    context "succesful search by distance" do
      subject { filter.filter_distance resources, { lat: -23.55961, lon: -46.731386, radius: 5 } }
      it { is_expected.to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "unsuccesful search by distance" do
      subject { filter.filter_distance resources, { lat: 10, lon: 10, radius: 5 } }
      it { is_expected.not_to include(resource1) }
      it { is_expected.not_to include(resource2) }
      it { is_expected.not_to include(resource3) }
    end
    context "search for no distance" do
      subject { filter.filter_distance resources, {} }
      it { is_expected.to include(resource1) }
      it { is_expected.to include(resource2) }
      it { is_expected.to include(resource3) }
    end
  end

end
