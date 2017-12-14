require 'geocoder'
require 'location'
require 'uuid'

class BasicResource < ApplicationRecord
  before_validation :create_uuid
  has_and_belongs_to_many :capabilities,
    after_add: :add_cache, after_remove: :remove_cache
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

  def capability_names(function = nil)
    names = self.get_cached_capabilities(function)
    return names if !names.blank? || self.capabilities.count == 0

    selected_capabilities = self.capabilities
    selected_capabilities = self.capabilities.send('all_' + function.to_s) unless function.blank?
    names = []
    selected_capabilities.each do |cap|
      names << cap.name
    end
    self.set_cached_capabilities(names, function)
    names
  end

  def to_json(function = nil)
    hash = attributes.to_options
    hash[:capabilities] = capability_names(function)
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

  def get_cached_capabilities(function = nil)
    function = "all" if function.nil?
    $redis.smembers("#{self.uuid}:#{function.to_s}")
  end

  def set_cached_capabilities(names, function = nil)
    return nil if names.blank?
    function = "all" if function.nil?
    $redis.sadd("#{self.uuid}:#{function.to_s}", names)
  end

  def remove_cached_capabilities(names, function = nil)
    function = "all" if function.nil?
    $redis.srem("#{self.uuid}:#{function.to_s}", names)
  end

  private

    def create_uuid
      self.uuid = SecureRandom.uuid if self.uuid.blank?
    end

    def uuid_format
      unless UUID.validate(self.uuid)
        errors.add(:uuid, "is not compatible with RFC 4122")
      end
    end

    def add_cache(capability)
      self.set_cached_capabilities(capability.name)
      if capability.sensor?
        self.set_cached_capabilities(capability.name, "sensors")
      elsif capability.actuator?
        self.set_cached_capabilities(capability.name, "actuators")
      end
    end

    def remove_cache(capability)
      self.remove_cached_capabilities(capability.name)
      if capability.sensor?
        self.remove_cached_capabilities(capability.name, "sensors")
      elsif capability.actuator?
        self.remove_cached_capabilities(capability.name, "actuators")
      end
    end
end
