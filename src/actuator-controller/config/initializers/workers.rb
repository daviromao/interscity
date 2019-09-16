if Rails.env.development? || Rails.env.production?
  require 'bunny'

  WORKERS_LOGGER ||= Logger.new("#{Rails.root}/log/workers.log")

  Rails.configuration.worker_conn = Bunny.new(
    hostname: SERVICES_CONFIG['services']['rabbitmq'],
    logger: WORKERS_LOGGER,
  )
  Rails.configuration.worker_conn.start

  resource_creator_worker = ResourceCreator.new(2, 2)
  resource_creator_worker.perform

  resource_updater_worker = ResourceUpdater.new(1, 1)
  resource_updater_worker.perform

  actuator_command_updater_worker = ActuatorCommandUpdater.new(1, 1)
  actuator_command_updater_worker.perform
end
