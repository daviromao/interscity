require 'geocoder'
require 'location'
require 'uuid'

class BasicResource < ApplicationRecord
  before_validation :create_uuid
  has_and_belongs_to_many :capabilities
  validates :lat, presence: true, numericality: true
  validates :lon, presence: true, numericality: true
  validates :status, presence: true
  validates :uuid, uniqueness: true
  validate :uuid_format

  def self.all_sensors
    joins(:capabilities).where("capabilities.function" => Capability.sensor_index)
  end

  def self.all_actuators
    joins(:capabilities).where("capabilities.function" => Capability.actuator_index)
  end

  def self.all_informations
    joins(:capabilities).where("capabilities.function" => Capability.information_index)
  end

  def sensor?
    self.capabilities.where(function: Capability.sensor_index).count > 0
  end

  def actuator?
    self.capabilities.where(function: Capability.actuator_index).count > 0
  end

  def to_json(function = nil)
    selected_capabilities = capabilities
    selected_capabilities = capabilities.send('all_' + function.to_s) unless function.blank?
    hash = attributes.to_options
    hash[:capabilities] = []
    selected_capabilities.each do |cap|
      hash[:capabilities] << cap.name
    end
    hash
  end

  def as_json(options = { })
    hash = super(options)
    capabilities_list = self.capabilities.pluck(:name)
    hash[:capabilities] = capabilities_list
    hash
  end

  reverse_geocoded_by :lat, :lon do |obj, results|
    geo = results.first
    if geo
      obj.postal_code  = SmartCities::Location.extract_postal_code(results)
      obj.neighborhood = SmartCities::Location.get_neighborhood(geo.address_components)
      obj.city         = geo.city
      obj.state        = geo.state
      obj.country      = geo.country
    end
  end

  after_validation :reverse_geocode

  private

    def create_uuid
      self.uuid = SecureRandom.uuid if self.uuid.blank?
    end

    def uuid_format
      unless UUID.validate(self.uuid)
        errors.add(:uuid, "is not compatible with RFC 4122")
      end
    end
end
