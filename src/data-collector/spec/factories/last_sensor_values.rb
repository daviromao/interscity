# frozen_string_literal: true

FactoryGirl.define do
  factory :last_sensor_value do
    initialize_with do
      obj = new
      obj.define_dynamic_writer('value')
      obj.define_dynamic_reader('value')
      obj
    end
    factory :default_last_value do
      date '2016-06-16 20:43:13'
      capability 'temperature'
      uuid { FactoryGirl.build(:essential_args).uuid }
      value '68.6345'
    end
    factory :default_last_value_2 do
      date '2016-06-16 20:43:13'
      capability 'temperature'
      uuid { FactoryGirl.build(:resource_default_2).uuid }
      value '68.6345'
    end
  end
end
