require "rest-client"
require 'service/base/kong_lib/wrapper'

if Rails.env.development? || Rails.env.production?
  register_method = ENV['REGISTER_METHOD'] || 'target'
  self_host = SERVICES_CONFIG['services']['self'] || 'data-collector:3000'

  wrapper = Service::Base::KongLib::Wrapper.new(self_host)

  if register_method == 'target'
    wrapper.register_as_target('collector', 'collector.v1.service', weight = 100)
  elsif register_method == 'api'
    wrapper.register_as_api('data-collector', ['/collector'])
  else
    Rails.logger.error "Registration method not supported: #{register_method}"
  end
end
