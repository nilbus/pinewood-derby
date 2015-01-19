if ENV['DEBUG']
  Celluloid.logger.level = ::Logger::DEBUG
else
  Celluloid.logger.level = ::Logger::INFO
end
