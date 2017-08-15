require "rest-client"

if Rails.env.development? || Rails.env.production?
  kong = SERVICES_CONFIG['services']['kong'] || 'kong:8001'
  self_host = SERVICES_CONFIG['services']['self'] || 'actuator-controller:3000'

  self_host = 'http://' + self_host unless self_host.start_with?('http')

  begin
    response = RestClient.post(
      kong + '/apis',
      {
        name: 'actuator-controller',
        upstream_url: self_host,
        uris: ['/actuator'],
        strip_uri: true
      }.to_json,
      {content_type: :json, accept: :json}
    )

    Rails.logger.error "API was succesfully registered to Kong: #{response}"
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "Could not register API to Kong #{e.response}"
  rescue StandardError => e
    Rails.logger.error "Could not register API to Kong #{e.message}"
  end
end
