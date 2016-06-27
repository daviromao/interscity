class ActuatorValue < ApplicationRecord
  belongs_to :platform_resource
  belongs_to :capability
end
