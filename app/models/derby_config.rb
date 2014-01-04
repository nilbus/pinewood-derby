require 'psych'
require 'singleton'

class DerbyConfig
  include Singleton

  CONFIG_FILE = File.expand_path(File.join(__FILE__, '../../../config/derby_config.yml'))

  def self.lane_count
    instance['lane_count'].to_i
  end

  def self.sensor_class
    sensor_class_name = instance['sensor_class_name']

    TrackSensor.const_get(sensor_class_name)
  end

  def self.device_glob
    instance['device_glob']
  rescue KeyError
    nil
  end

  def initialize
    reload
  end

  def reload
    yaml = File.read CONFIG_FILE
    @config = Psych.load yaml
  end

  def [](key)
    key = key.to_s
    @config.fetch key
  rescue KeyError
    raise KeyError, "#{CONFIG_FILE} does not contain the setting #{key.inspect}"
  end
end
