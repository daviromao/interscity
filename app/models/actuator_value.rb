class ActuatorValue < ApplicationRecord
  belongs_to :resource
  belongs_to :capability
end