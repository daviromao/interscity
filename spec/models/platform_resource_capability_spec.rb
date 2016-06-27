require 'rails_helper'

RSpec.describe PlatformResourceCapability, type: :model do
  let(:platform_resource_capability) do
    FactoryGirl.build(:platform_resource_capability)
  end

  it 'has a valid factory' do
    expect(platform_resource_capability).to be_valid
  end

  it 'belongs to one capability' do
    expect(platform_resource_capability.capability_id).not_to be_nil
    expect(platform_resource_capability.capability_id).not_to eq('')

    expect(FactoryGirl.build(:platform_resource_capability,
                             capability_id: '')).not_to be_valid
    expect(FactoryGirl.build(:platform_resource_capability,
                             capability_id: nil)).not_to be_valid
  end

  it 'belongs to one resource' do
    expect(platform_resource_capability.platform_resource_id).not_to be_nil
    expect(platform_resource_capability.platform_resource_id).not_to eq('')

    expect(FactoryGirl.build(:platform_resource_capability,
                             platform_resource_id: '')).not_to be_valid
    expect(FactoryGirl.build(:platform_resource_capability,
                             platform_resource_id: nil)).not_to be_valid
  end
end
