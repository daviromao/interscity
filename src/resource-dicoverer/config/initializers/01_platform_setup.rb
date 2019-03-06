require 'yaml'

SERVICES_FILE = File.read(Rails.root.join("config", "services.yml"))
SERVICES_ERB = ERB.new(SERVICES_FILE)
SERVICES_CONFIG = YAML.load(SERVICES_ERB.result)
SERVICES_CONFIG['services']['catalog'] ||= "resource-cataloguer:3000"
SERVICES_CONFIG['services']['collector'] ||= "data-collector:3000"
