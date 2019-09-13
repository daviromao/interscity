# frozen_string_literal: true

require 'notification'

class ActuatorCommand < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include SmartCities::Notifier
  include Filterable

  field :uuid, type: String
  field :status, type: String, default: 'pending'
  field :capability, type: String
  field :value

  validates :uuid, :status, :capability, :value, presence: true
  validates :status, inclusion: {
    in: %w[pending failed processed rejected]
  }

  belongs_to :platform_resource, dependent: :nullify

  scope :status, ->(status) { where status: status }
  scope :uuid, ->(uuid) { where uuid: uuid }
  scope :capability, ->(capability) { where capability: capability }
  scope :recent, -> { order_by(created_at: 'desc') }

  after_create :publish_command

  protected

  def publish_command
    notify_command_request(self)
  rescue StandardError
    self.status = 'failed'
    save
  end
end
