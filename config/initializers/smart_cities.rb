require 'yaml'

SERVICES_CONFIG = YAML.load_file(Rails.root.join("config", "services.yml"))

