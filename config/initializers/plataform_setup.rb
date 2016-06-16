require 'yaml'

#include test just for coverage purpose. Later remove.
if Rails.env.development? || Rails.env.production? || Rails.env.test?   
  SERVICES_CONFIG = YAML.load_file(Rails.root.join("config", "services.yml"))
end
