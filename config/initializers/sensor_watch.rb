running_rails_server = defined? Rails::Server
if running_rails_server
  $sensor_watch = SensorWatch.new debug: ENV['DEBUG']
  $sensor_watch.async.monitor
end
