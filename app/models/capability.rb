class Capability < ApplicationRecord
  has_many :actuator_values
  has_many :has_capabilities
  has_many :resources, :through => :actuator_values
  has_many :resources, :through => :has_capabilities
end