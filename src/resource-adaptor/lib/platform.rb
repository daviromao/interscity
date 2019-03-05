require 'json'

module Platform
  module ResourceManager
    def self.register_resource(data)
      begin
        response = RestClient.post(
          SERVICES_CONFIG['services']['catalog'] + "/resources",
          {data: data}
        )
        return response
      rescue RestClient::Exception => e
        return e.response
      rescue StandardError => e
        puts "Could not register Resource - ERROR #{e}"
        return nil
      end
    end

    def self.update_resource(uuid, data)
      begin
        response = RestClient.put(
          SERVICES_CONFIG['services']['catalog'] + "/resources/#{uuid}",
          {data: data}
        )
        return response
      rescue RestClient::Exception => e
        return e.response
      rescue StandardError => e
        puts "Could not register Resource - ERROR #{e}"
        return nil
      end
    end

    def self.get_resource(uuid)
      begin
        response = RestClient.get(
          SERVICES_CONFIG['services']['catalog'] + "/resources/#{uuid}")
        return response
      rescue RestClient::Exception => e
        return e.response
      rescue StandardError => e
        puts "Could not register Resource - ERROR #{e}"
        return nil
      end
    end
  end
end
