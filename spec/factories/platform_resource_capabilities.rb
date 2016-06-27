FactoryGirl.define do
  factory :platform_resource_capability do
    transient do
      capability_name 'temperature'
      resource_uuid 'ab631116-2837-11e6-b67b-9e71128cae77'
    end

    capability do
      Capability.find_by(name: capability_name) ||
        FactoryGirl.create(:capability, name: capability_name)
    end

    platform_resource do
      PlatformResource.find_by(uuid: resource_uuid) ||
        FactoryGirl.create(:empty_capability, uuid: resource_uuid)
    end
  end
end
