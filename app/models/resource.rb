class Resource < ApplicationRecord
  has_many :actuator_values
  has_many :capabilities, :through => :actuator_values
end
