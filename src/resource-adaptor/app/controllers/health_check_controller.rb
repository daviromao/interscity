# frozen_string_literal: true

class HealthCheckController < ApplicationController
  def index
    render json: { healthy: true, message: 'success' }, status: :ok
  end
end
