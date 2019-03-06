LOGGER ||= Logger.new("#{Rails.root}/log/thread_update.log")
LOGGER.level = Logger::ERROR

LOGGER_DB ||= Logger.new("#{Rails.root}/log/thread_update_bd.log")
LOGGER_DB.level = Logger::ERROR
