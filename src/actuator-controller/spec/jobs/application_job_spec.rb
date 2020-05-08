# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob do
  it 'is expected to be and ActionCable channel' do
    expect(described_class).to be < ActiveJob::Base
  end
end
