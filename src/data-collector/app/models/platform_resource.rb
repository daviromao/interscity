# frozen_string_literal: true

class PlatformResource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri, type: String
  field :uuid, type: String
  field :status, type: String
  field :capabilities, type: Array, default: []
  field :collect_interval, type: Integer

  index({ uuid: 1 }, name: 'platform_resource_uuid_index')

  has_many :sensor_values

  validates :uuid, :status, presence: true
end
