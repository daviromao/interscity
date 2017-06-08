require 'notification'

class ActuatorCommand < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include SmartCities::Notifier

  field :uuid, type: String
  field :status, type: String, default: "pending"
  field :capability, type: String
  field :value

  validates :uuid, :status, :capability, :value, presence: true
  validates :status, inclusion: {
    in: ["pending", "failed", "processed", "rejected"]
  }

  belongs_to :platform_resource, dependent: :nullify

  after_create :publish_command

  protected

  def publish_command
    begin
      notify_command_request(self)
    rescue StandardError => e
      self.status = "failed"
      self.save
    end
  end
end
