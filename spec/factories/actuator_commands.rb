# frozen_string_literal: true
# Defines factories for creating PlatformResource objects
FactoryGirl.define do
  # Abstract factory for PlatformResource
  factory :actuator_command do
    association :platform_resource, factory: :with_capability

    factory :valid_actuator_command do
      uuid { platform_resource.uuid }
      capability { platform_resource.capabilities.first }
      value 10
    end

    factory :actuator_command_with_missing_attributes do
    end
  end
end
