class Capability < ApplicationRecord
  has_many :actuator_values
  has_many :resources, :through => :actuator_values
end