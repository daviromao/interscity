LOGGER ||= Logger.new("#{Rails.root}/log/data_collect.log")
LOGGER.level = Logger::ERROR

RESOURCE_LOGGER ||= Logger.new("#{Rails.root}/log/resource_create.log")
RESOURCE_LOGGER.level = Logger::ERROR
