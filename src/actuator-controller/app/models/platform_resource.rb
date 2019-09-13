# frozen_string_literal: true

class PlatformResource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uuid, type: String
  field :status, type: String
  field :capabilities, type: Array, default: []

  validates :uuid, :status, presence: true
  has_many :actuator_commands, dependent: :delete
end
