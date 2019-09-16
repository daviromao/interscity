if Rails.env.development? || Rails.env.production?
  require 'bunny'

  WORKERS_LOGGER ||= Logger.new("#{Rails.root}/log/workers.log")

  Rails.configuration.worker_conn = Bunny.new(
    hostname: SERVICES_CONFIG['services']['rabbitmq'],
    logger: WORKERS_LOGGER,
  )
  Rails.configuration.worker_conn.start

  location_updater_worker = LocationUpdater.new(2, 2)
  location_updater_worker.perform
end
