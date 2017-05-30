# frozen_string_literal: true
class PlatformResource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri, type: String
  field :uuid, type: String
  field :status, type: String
  field :capabilities, type: Array, default: []
  field :collect_interval, type: Integer

  validates :uuid, :status, presence: true
end
