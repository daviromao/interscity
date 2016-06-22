class Resource < ApplicationRecord
  has_many :actuator_values
  has_many :has_capabilities
  has_many :capabilities, :through => :actuator_values
  has_many :capabilities, :through => :has_capabilities
end
