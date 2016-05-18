require 'rails_helper'

RSpec.describe DiscoveryController, :type => :controller do
	describe '#resources' do
		it 'should return status 400 (Bad Request)' do
			get 'resources', format: :json
			expect(response.status).to eq(400)
		end
		#it {expect(response.status).to eq(200)}

		it 'should return 1 params' do
			get 'resources', params: {capability: "temp"}

			expect(JSON.parse(response.body)["data"]["capability"]).
			       to eq("temp")
			expect(response.status).to eq(200)
		end

	end

end
