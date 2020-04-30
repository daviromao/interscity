# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Channel do
  it 'is expected to be and ActionCable channel' do
    expect(described_class).to be < ActionCable::Channel::Base
  end
end
