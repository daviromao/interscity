class ActuatorCommand < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uuid, type: String
  field :status, type: String, default: "pending"
  field :capability, type: String
  field :value

  validates :uuid, :status, :value, presence: true
  validates :status, inclusion: {
    in: ["pending", "failed", "processed"]
  }

  belongs_to :platform_resource, dependent: :nullify
end
