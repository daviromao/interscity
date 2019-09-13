# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Subscription, type: :model do
  let(:subscription) { Subscription.new }

  context 'validations' do
    subject { subscription.errors }
    before do
      subscription.valid?
    end

    describe '#uuid' do
      it { is_expected.to have_key(:uuid) }
    end

    describe '#url' do
      it { is_expected.to have_key(:url) }
    end

    describe '#capabilities' do
      it { is_expected.to have_key(:capabilities) }
    end
  end
end
