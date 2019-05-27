# frozen_string_literal: true

class LastSensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in client: 'cache'

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  index({ uuid: 1 }, name: 'last_uuid_index')
  index({ capability: 1 }, name: 'last_capability_index')
  index({ uuid: 1, capability: 1 }, name: 'last_capability_uuid_index')

  validates :date, :capability, :uuid, presence: true

  def self.static_attributes
    %w[_id created_at updated_at capability uuid date]
  end

  def dynamic_attributes
    attributes.except(*SensorValue.static_attributes)
  end
end
