# frozen_string_literal: true

FactoryGirl.define do
  factory :sensor_value do
    initialize_with do
      obj = new
      obj.define_dynamic_writer('temperature')
      obj.define_dynamic_reader('temperature')
      obj.define_dynamic_writer('pressure')
      obj.define_dynamic_reader('pressure')
      obj
    end
    factory :default_sensor_value do
      date '2016-06-16 20:43:13'
      capability 'temperature'
      association :platform_resource, factory: :essential_args,
                                      strategy: :build
      temperature '68.6345'
      pressure '5.76'
    end
    factory :default_sensor_value_2 do
      date '2016-06-16 20:43:13'
      capability 'temperature'
      association :platform_resource, factory: :resource_default_2,
                                      strategy: :build
      temperature '118.6345'
      pressure '15.76'
    end
  end
end
