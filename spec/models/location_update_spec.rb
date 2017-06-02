require 'rails_helper'

RSpec.describe LocationUpdate, :type => :model do

    let!(:updater) { LocationUpdate.new }

    describe '#simple_perform' do
      it 'performs' do
        updater.perform
      end
    end

end
