class ValidateParams

  def self.validate_cap_exec (json)
    if (json.key?('uuid') and json.key?('capability'))

      if(not json['uuid'].blank? and not json['capability'].blank?)

        return true
      end
    end
    return false
  end

  def self.validate_resource_catalog_update (json)

    if (json.key?('uuid') and json.key?('uri') and json.key?('name'))
      if(not json['uuid'].blank? and not json['uri'].blank? and not json['name'].blank?)
        return true
      end
    end
    return false
  end

  def self.validate_resource_catalog_creation (json)

    if (json.key?('uuid') and json.key?('uri') and json.key?('name'))
      if(not json['uuid'].blank? and not json['uri'].blank? and not json['name'].blank?)
        return true
      end
    end
    return false
  end

end