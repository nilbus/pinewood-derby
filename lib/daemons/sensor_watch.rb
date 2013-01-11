#!/usr/bin/env ruby

# Load the Rails environment
ENV["RAILS_ENV"] ||= "development"
# ENV["RAILS_ENV"] ||= "production"
root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
require File.join(root, "config", "environment")

require 'sensor_watch'

$running = true
Signal.trap("TERM") do
  $running = false
end

sensor_watch = SensorWatch.new

Signal.trap("USR1") do
  sensor_watch.start_race
end

# Rewrite pidfile in case we're running in the foreground
File.write(SensorWatch.daemon_pid_filename, Process.pid)

while($running) do
  sensor_watch.tick
  sleep 0.2
end
sensor_watch.quit
