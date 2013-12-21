require 'psych'
require 'singleton'

class DerbyConfig
  include Singleton

  CONFIG_FILE = 'config/derby_config.yml'

  def self.lane_count
    instance['lane_count'].to_i
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
