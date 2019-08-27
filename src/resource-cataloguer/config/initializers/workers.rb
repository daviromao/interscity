if Rails.env.development? || Rails.env.production?
  require 'bunny'

  WORKERS_LOGGER ||= Logger.new("#{Rails.root}/log/workers.log")

  $conn = Bunny.new(
    hostname: SERVICES_CONFIG['services']['rabbitmq'],
    logger: WORKERS_LOGGER,
  )
  $conn.start

  location_updater_worker = LocationUpdater.new(2, 2)
  location_updater_worker.perform
end
