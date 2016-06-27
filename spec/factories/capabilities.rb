FactoryGirl.define do
  factory :capability do
    name 'temperature'
    initialize_with { Capability.find_or_create_by(name: name)}
  end
end
