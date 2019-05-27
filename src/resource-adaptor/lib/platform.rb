# frozen_string_literal: true

require 'json'

module Platform
  module ResourceManager
    def self.register_resource(data)
      response = RestClient.post(
        SERVICES_CONFIG['services']['catalog'] + '/resources',
        data: data
      )
      response
    rescue RestClient::Exception => e
      e.response
    rescue StandardError => e
      puts "Could not register Resource - ERROR #{e}"
      nil
    end

    def self.update_resource(uuid, data)
      response = RestClient.put(
        SERVICES_CONFIG['services']['catalog'] + "/resources/#{uuid}",
        data: data
      )
      response
    rescue RestClient::Exception => e
      e.response
    rescue StandardError => e
      puts "Could not register Resource - ERROR #{e}"
      nil
    end

    def self.get_resource(uuid)
      response = RestClient.get(
        SERVICES_CONFIG['services']['catalog'] + "/resources/#{uuid}"
      )
      response
    rescue RestClient::Exception => e
      e.response
    rescue StandardError => e
      puts "Could not register Resource - ERROR #{e}"
      nil
    end
  end
end
