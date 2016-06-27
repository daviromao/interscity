class PlatformResourceCapability < ApplicationRecord

  belongs_to :capability
  belongs_to :platform_resource

  validates_uniqueness_of :capability_id, scope: :platform_resource

end
