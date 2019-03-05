# frozen_string_literal: true
class SensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  index({ uuid: 1 }, { name: "sensor_uuid_index" })
  index({ capability: 1 }, { name: "sensor_capability_index" })
  index({ uuid: 1, capability: 1 }, { name: "sensor_capability_uuid_index" })

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true

  before_save :parse_to_float
  before_save :set_uuid
  before_create :save_last_value

  def self.static_attributes
    ["_id", "created_at", "updated_at", "capability", "uuid",
     "platform_resource_id"]
  end

  def dynamic_attributes
    self.attributes.except(*SensorValue.static_attributes)
  end

  private

  def save_last_value
    sensor_last = LastSensorValue.find_or_create_by(
      uuid: self.uuid,
      capability: self.capability,
    )
    new_attributes = self.dynamic_attributes
    new_attributes.each {|attribute, value| sensor_last.process_attribute(attribute, value)}
    sensor_last.save!
  end

  def parse_to_float
    self.attributes.each do |key, value|
      if value.try(:is_float?)
        self[key.to_sym] = value.to_f
      end
    end
  end

  def set_uuid
    self.uuid = self.platform_resource.uuid
  end
end
