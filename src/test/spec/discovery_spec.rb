# frozen_string_literal: true

require 'spec_helper'
require 'requests_helper'

RSpec.configure do |c|
  c.include RequestsHelper
end

RSpec.describe '/discovery' do
  describe '/resources' do
    describe 'GET /' do
      context 'passing a filter' do
        let(:filter) { 'capability=temperature' }

        before do
          @response = connection.get("discovery/resources?#{filter}")
        end

        it 'is expected to respond with success' do
          expect(@response.status).to be(200)
        end

        it 'is expected to return a list of resources' do
          json = response_json(@response)

          expect(json['resources']).to be_an_instance_of(Array)
        end
      end

      context 'without passing a filter' do
        before do
          @response = connection.get('discovery/resources')
        end

        it 'is expected to return an error' do
          expect(@response.status).to be(400)
        end
      end
    end
  end
end
