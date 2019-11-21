# frozen_string_literal: true

require 'faraday'
require 'json'

module RequestsHelper
  def connection
    url = ENV.fetch('ISCITY_URL') { 'http://10.10.10.104:8000' }

    @conn ||= Faraday.new(url: url, request: { timeout: 2 })

    @conn
  end

  def response_json(response)
    JSON.parse(response.body)
  end
end
