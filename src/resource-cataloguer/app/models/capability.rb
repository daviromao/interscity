# frozen_string_literal: true

class Capability < ApplicationRecord
  validates :function, inclusion: { in: 0..2, message: 'Bad capability_type' }
  validates :name, uniqueness: true, presence: true
  has_and_belongs_to_many :basic_resources

  TYPES = %i[sensor actuator information].freeze
  TYPE_INDEX = {
    sensor: 0, actuator: 1, information: 2
  }.freeze

  def capability_type
    function_symbol
  end

  def function_symbol
    TYPES[self[:function]]
  end

  def function?(function_symbol)
    TYPES[self[:function]] == function_symbol
  end

  def sensor?
    function? :sensor
  end

  def actuator?
    function? :actuator
  end

  def information?
    function? :information
  end

  def self.valid_function?(function_symbol)
    TYPES.include? function_symbol
  end

  def self.function_index(function_symbol)
    TYPE_INDEX[function_symbol]
  end

  def self.sensor_index
    function_index :sensor
  end

  def self.actuator_index
    function_index :actuator
  end

  def self.information_index
    function_index :information
  end

  def self.all_sensors
    all_of_function :sensor
  end

  def self.all_actuators
    all_of_function :actuator
  end

  def self.all_informations
    all_of_function :information
  end

  def self.all_of_function(function_symbol)
    where(function: function_index(function_symbol))
  end

  def self.create_with_function(function_symbol, params)
    Capability.create(params.merge(function: function_index(function_symbol)))
  end

  def self.create_sensor(params)
    create_with_function(:sensor, params)
  end

  def self.create_actuator(params)
    create_with_function(:actuator, params)
  end

  def self.create_information(params)
    create_with_function(:information, params)
  end
end
