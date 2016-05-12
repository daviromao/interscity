require 'rails_helper'

RSpec.describe DiscoveryController, :type => :controller do
	describe '#resources' do
		#it 'should return status 200 OK' do
			#expect(response.status).to eq(200)
		#end
		it {expect(response.status).to eq(200)}
	end

end
