require "rest-client"

if Rails.env.development? || Rails.env.production?
  register_method = ENV['REGISTER_METHOD'] || 'target'
  self_host = SERVICES_CONFIG['services']['self'] || 'resource-catalog:3000'

  wrapper = Kong::Wrapper.new(self_host)

  if register_method == 'target'
    wrapper.register_as_target('catalog', 'catalog.v1.service', weight = 100)
  elsif register_method == 'api'
    wrapper.register_as_api('resource-catalog', ['/catalog'])
  else
    Rails.logger.error "Registration method not supported: #{register_method}"
  end
end
