# frozen_string_literal: true

require 'faraday'

module RequestsHelper
  def connection
    url = ENV.fetch('ISCITY_URL') { 'http://10.10.10.104:8000' }

    @conn ||= Faraday.new(url: url, request: { timeout: 1 })

    @conn
  end
end
