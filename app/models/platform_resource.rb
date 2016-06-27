class PlatformResource < ApplicationRecord

  has_many :platform_resource_capabilities
  has_many :capabilities, through: :platform_resource_capabilities
  has_many :sensor_values

  validates :uri, :uuid, :status, :collect_interval, presence: true

end
