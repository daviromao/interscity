# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlatformResource, type: :model do
  let(:platform_resource) { FactoryGirl.build(:empty_capability) }

  it 'has a valid factory' do
    expect(platform_resource).to be_valid
  end

  it 'has an uri' do
    expect(platform_resource.uri).not_to be_nil
    expect(platform_resource.uri).not_to eq('')
  end

  it 'has a valid uuid' do
    expect(platform_resource.uuid).not_to be_nil
    expect(platform_resource.uuid).not_to eq('')

    expect(FactoryGirl.build(:empty_capability,
                             uuid: '')).not_to be_valid
    expect(FactoryGirl.build(:empty_capability,
                             uuid: nil)).not_to be_valid

    uuid_pattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    expect(uuid_pattern.match(platform_resource.uuid)).not_to be_nil
  end

  it 'has a status' do
    expect(platform_resource.status).not_to be_nil
    expect(platform_resource.status).not_to eq('')

    expect(FactoryGirl.build(:empty_capability,
                             status: '')).not_to be_valid
    expect(FactoryGirl.build(:empty_capability,
                             status: nil)).not_to be_valid
  end

  it 'has a collect interval' do
    expect(platform_resource.collect_interval).not_to be_nil
    expect(platform_resource.collect_interval).not_to eq('')
  end
end
