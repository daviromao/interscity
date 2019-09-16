# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe 'catalog' do
  describe 'GET resources' do
    it 'is expected to respond with success' do
      response = connection.get('catalog/resources')

      expect(response.status).to be(200)
    end
  end
end
