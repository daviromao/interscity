# frozen_string_literal: true

class Subscription < ApplicationRecord
  validates :uuid, presence: true
  validates :url, presence: true
  validates :capabilities, presence: true
end
