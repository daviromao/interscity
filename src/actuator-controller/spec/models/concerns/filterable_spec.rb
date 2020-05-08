# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterable do
  subject do
    Class.new do
      include Filterable

      def self.where(_); end
    end
  end

  it 'is expected to respond to #filter' do
    expect(subject).to respond_to(:filter)
  end

  describe 'filter' do
    let(:results) { double('results') }
    let(:valid_filter) { ['a', 1] }
    let(:invalid_filter) { ['b', ''] }
    let(:filters) { [valid_filter, invalid_filter].to_h }

    before do
      allow(subject).to receive(:where).and_return(results)
      allow(results).to receive(:public_send).and_return(results)

      @result = subject.filter filters
    end

    it 'is expected to start with all the values' do
      expect(subject).to have_received(:where).with(nil)
    end

    it 'is expected to filter the values using our parameters' do
      expect(results).to have_received(:public_send).with(*valid_filter)
      expect(results).not_to have_received(:public_send).with(*invalid_filter)
    end

    it 'is expected to return the results' do
      expect(@result).to eq(results)
    end
  end
end
