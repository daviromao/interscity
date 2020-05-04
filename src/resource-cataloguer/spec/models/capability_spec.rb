# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Capability, type: :model do
  subject { Capability.new(name: 'temperature', function: Capability.sensor_index) }

  describe 'validation' do
    it { is_expected.to validate_inclusion_of(:function).in_range(0..2).with_message('Bad capability_type') }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'association' do
    it { is_expected.to have_and_belong_to_many(:basic_resources) }
  end

  describe 'instance method' do
    describe 'capability_type' do
      let(:type) { Capability::TYPES.first }

      before do
        allow(subject).to receive(:function_symbol).and_return(type)

        @capability_type = subject.capability_type
      end

      it 'is expected to call function_symbol' do
        expect(subject).to have_received(:function_symbol)
      end

      it 'is expected to return the capability_type' do
        expect(@capability_type).to eq(type)
      end
    end

    describe 'function_symbol' do
      it 'is expected to return the function_symbol' do
        expect(subject.function_symbol).to eq(Capability::TYPES[subject.function])
      end
    end

    describe 'function?' do
      let(:function_symbol) { nil }

      before do
        @is_function = subject.function?(function_symbol)
      end

      context 'with the same function symbol' do
        let(:function_symbol) { Capability::TYPES[subject.function] }

        it 'is expected to return true' do
          expect(@is_function).to eq(true)
        end
      end

      context 'with a different function symbol' do
        let(:function_symbol) { :something_else }

        it 'is expected to return false' do
          expect(@is_function).to eq(false)
        end
      end
    end

    described_class::TYPES.each do |type|
      describe "#{type}?" do
        let(:is_function) { true }

        before do
          allow(subject).to receive(:function?).and_return(is_function)

          @is_type = subject.send("#{type}?")
        end

        it 'is epxected to call function?' do
          expect(subject).to have_received(:function?).with(type)
        end

        it 'is expected to return if it is that type of function' do
          expect(@is_type).to eq(is_function)
        end
      end
    end
  end

  describe 'class method' do
    describe 'valid_function?' do
      let(:function) { nil }

      before do
        @is_valid_function = described_class.valid_function?(function)
      end

      context 'with a valid type' do
        let(:function) { described_class::TYPES.first }

        it 'is expected to return true' do
          expect(@is_valid_function).to eq(true)
        end
      end

      context 'with a invalid type' do
        let(:function) { :anything_else }

        it 'is expected to return false' do
          expect(@is_valid_function).to eq(false)
        end
      end
    end

    describe 'function_index' do
      it 'is expected to return the TYPE index from TYPE_INDEX' do
        described_class::TYPES.each do |type|
          expect(described_class.function_index(type)).to be_an(Integer)
        end
      end
    end

    described_class::TYPES.each do |type|
      describe "#{type}_index" do
        let(:function_index) { 42 }

        before do
          allow(described_class).to receive(:function_index).and_return(function_index)

          @returned_index = described_class.send("#{type}_index")
        end

        it "is expected to return the index for the #{type} type" do
          expect(@returned_index).to eq(function_index)
        end

        it 'is expected to use the function_index method' do
          expect(described_class).to have_received(:function_index).with(type)
        end
      end

      describe "all_#{type}" do
        let(:capabilities) { double('capabilities') }

        before do
          allow(described_class).to receive(:all_of_function).and_return(capabilities)

          @returned_capabilities = described_class.send("all_#{type}s")
        end

        it "is expected to return the capabilities of #{type} type" do
          expect(@returned_capabilities).to eq(capabilities)
        end

        it 'is expected to use the all_of_function method' do
          expect(described_class).to have_received(:all_of_function).with(type)
        end
      end

      describe "create_#{type}" do
        let(:params) { double('params') }
        let(:created) { double('created') }

        before do
          allow(described_class).to receive(:create_with_function).and_return(created)

          @created_with_function = described_class.send("create_#{type}", params)
        end

        it "is expected to return the created capability of #{type} type" do
          expect(@created_with_function).to eq(created)
        end

        it 'is expected to use the create_with_function method' do
          expect(described_class).to have_received(:create_with_function).with(type, params)
        end
      end
    end

    describe 'all_of_function' do
      let(:all_of_function) { double('all_of_function') }
      let(:function_symbol) { :something }
      let(:function_index) { 1 }

      before do
        allow(described_class).to receive(:where).and_return(all_of_function)
        allow(described_class).to receive(:function_index).and_return(function_index)

        @returned_capabilities = described_class.all_of_function(function_symbol)
      end

      it 'is expected to return the queried capabilities' do
        expect(@returned_capabilities).to eq(all_of_function)
      end

      it 'is expected to query the database for capabilities of the function type by its index' do
        expect(described_class).to have_received(:function_index).with(function_symbol)
        expect(described_class).to have_received(:where).with(function: function_index)
      end
    end

    describe 'create_with_function' do
      let(:params) { { something: 'from nothing' } }
      let(:function_symbol) { :useful_function }
      let(:function_index) { 1 }
      let(:created) { double('created') }

      before do
        allow(described_class).to receive(:function_index).and_return(function_index)
        allow(described_class).to receive(:create).and_return(created)

        @returned_capability = described_class.create_with_function(function_symbol, params)
      end

      it "is expected to return the created #{described_class}" do
        expect(@returned_capability).to eq(created)
      end

      it "is expected to create a #{described_class} with the params and respective function index" do
        expect(described_class).to have_received(:function_index).with(function_symbol)
        expect(described_class).to have_received(:create).with(params.merge(function: function_index))
      end
    end
  end
end
