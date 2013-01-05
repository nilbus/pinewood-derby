#!/usr/bin/env ruby

# Load the Rails environment
ENV["RAILS_ENV"] ||= "development"
# ENV["RAILS_ENV"] ||= "production"
root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
require File.join(root, "config", "environment")

require 'sensor_watch'

def log(message, level = :info)
  Rails.logger.send level, message
  Rails.logger.flush
end

$running = true
Signal.trap("TERM") do
  $running = false
end

sensor_watch = SensorWatch.new

Signal.trap("USR1") do
  sensor_watch.start_race
end
Signal.trap("USR2") do
  sensor_watch.output_state
end

while($running) do
  sensor_watch.tick
  sleep 0.2
end
sensor_watch.quit
