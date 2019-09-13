if Rails.env.development? || Rails.env.production?
  require 'bunny'

  WORKERS_LOGGER ||= Logger.new("#{Rails.root}/log/workers.log")

  Rails.configuration.worker.conn = Bunny.new(
    hostname: SERVICES_CONFIG['services']['rabbitmq'],
    logger: WORKERS_LOGGER,
  )
  Rails.configuration.worker.conn.start

  actuator_command_notifier_worker = ActuatorCommandNotifier.new(1, 1)
  actuator_command_notifier_worker.perform
end
