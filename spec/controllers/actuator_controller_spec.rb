require 'rails_helper'

describe ActuatorController, :type => :controller do

  describe '#resources' do
=begin


    before(:all) do
      @controller = ActuatorController.new

    end
    
=end
    
    it 'should run a capabilily from a determined url' do
      get "exec", :uuid => "123123", :capability => "temperature"
      debugger
      pending "This test is under construction"
    end

=begin    
    it 'should return status 400 (Bad Request)' do
      get 'resources'

      expect(response.status).to eq(400)
    end

=end
  end
end