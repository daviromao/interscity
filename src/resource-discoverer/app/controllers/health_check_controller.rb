class HealthCheckController < ApplicationController
  def index
    render json: {healthy: true, message: "success"}, status: 200
  end
end
