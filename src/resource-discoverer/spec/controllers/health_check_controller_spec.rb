require 'rails_helper'
require 'spec_helper'

describe HealthCheckController do
  describe '#index' do
    it "returns a success response" do
      get 'index', format: :json
      expect(response.status).to eq(200)
    end
  end
end
