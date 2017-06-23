require 'bunny'

begin
  updater = LocationUpdate.new
  updater.perform
rescue Bunny::TCPConnectionFailedForAllHosts
  LOGGER.error("Could not establish TCP connection to rabbitmq!")
end
