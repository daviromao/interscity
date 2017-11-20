module SmartCities

  module ResourceFilter

    def filter_resources resources, param_name, value
      resources.where(param_name => value)
    end

    def filter_capabilities resources, params
      if params[:capability].present?
        capability = Capability.find_by_name(params[:capability])
        id = capability.blank? ? -1 : capability.id
        resources = resources.joins(:capabilities).where(capabilities: {id: id}).preload(:capabilities)
      end
      resources
    end

    def filter_position resources, params
      if params[:lat].present? and params[:lon].present? and params[:radius].blank?
        resources = resources.where(lat: params[:lat], lon: params[:lon])
      end
      resources
    end

    def filter_distance resources, params
      if params[:lat].present? and params[:lon].present? and params[:radius].present?
        resources = resources.near([params[:lat], params[:lon]], params[:radius].to_f/1000.0, units: :km)
      end
      resources
    end

  end

end
