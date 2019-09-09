# frozen_string_literal: true

module SmartCities
  class Location
    def self.extract_postal_code(results)
      return nil if results.blank?

      first_pc = results.first.postal_code
      return nil if first_pc.nil?

      return first_pc if first_pc.length == 9 # Length of a postal code in BR

      # The first postal code has only 5 digits
      results.drop(1).each do |result|
        result_pc = result.postal_code
        return result_pc if /#{first_pc}-[0-9]{3}/.match result_pc
      end

      # There is no postal code with 9 digits
      first_pc << '000'
    end

    def self.get_neighborhood(address)
      neighborhood = nil
      address.each do |component|
        if component['types'].include? 'sublocality'
          neighborhood = component['long_name']
          break
        end
      end
      neighborhood
    end
  end
end
