require 'rails_helper'

RSpec.describe Capability, type: :model do

  let(:capability) {
    FactoryGirl.build(:capability)
  }

  it 'has a valid factory' do
    expect(capability).to be_valid
  end

  it 'has a name' do
    expect(capability.name).not_to be_nil
    expect(capability.name).not_to eq('')

    expect(FactoryGirl.build(:capability , name: '')).not_to be_valid
    expect(FactoryGirl.build(:capability , name: nil)).not_to be_valid
  end
end
