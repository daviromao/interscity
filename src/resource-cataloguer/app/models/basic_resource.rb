# frozen_string_literal: true

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
    joins(:capabilities).where('capabilities.function' => Capability.sensor_index)
  end

  def self.all_actuators
    joins(:capabilities).where('capabilities.function' => Capability.actuator_index)
  end

  def self.all_informations
    joins(:capabilities).where('capabilities.function' => Capability.information_index)
  end

  def sensor?
    capabilities.where(function: Capability.sensor_index).exists?
  end

  def actuator?
    capabilities.where(function: Capability.actuator_index).exists?
  end

  def capability_names(function = nil)
    names = get_cached_capabilities(function)
    return names if names.present? || !capabilities.exists?

    selected_capabilities = capabilities
    selected_capabilities = capabilities.send('all_' + function.to_s) if function.present?
    names = selected_capabilities.pluck(:name)
    set_cached_capabilities(names, function)
    names
  end

  def to_json(function = nil)
    hash = attributes.to_options
    hash[:capabilities] = capability_names(function)
    hash
  end

  def as_json(options = {})
    hash = super(options)
    capabilities_list = capability_names
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
    function = 'all' if function.nil?
    Rails.configuration.redis.smembers("#{uuid}:#{function}")
  end

  def set_cached_capabilities(names, function = nil)
    return nil if names.blank?

    function = 'all' if function.nil?
    Rails.configuration.redis.sadd("#{uuid}:#{function}", names)
  end

  def remove_cached_capabilities(names, function = nil)
    function = 'all' if function.nil?
    Rails.configuration.redis.srem("#{uuid}:#{function}", names)
  end

  private

  def create_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def uuid_format
    errors.add(:uuid, 'is not compatible with RFC 4122') unless UUID.validate(uuid)
  end

  def add_cache(capability)
    set_cached_capabilities(capability.name)
    if capability.sensor?
      set_cached_capabilities(capability.name, 'sensors')
    elsif capability.actuator?
      set_cached_capabilities(capability.name, 'actuators')
    end
  end

  def remove_cache(capability)
    remove_cached_capabilities(capability.name)
    if capability.sensor?
      remove_cached_capabilities(capability.name, 'sensors')
    elsif capability.actuator?
      remove_cached_capabilities(capability.name, 'actuators')
    end
  end
end
