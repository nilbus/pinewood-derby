# Tracks the sensor and race state.
# SensorWatch subscribes to the Celluloid::Notifications topic "race results".
# On that event, it updates SensorState, Heat, and Run database records, so
# Observers can take care of the updates.
#
class SensorWatch
  include Celluloid
  include Celluloid::Notifications

  def self.start_race
    $sensor_watch.async.start_race
  end

  def initialize(options = {})
    debug           = options[:debug]
    @logger         = options[:logger]       || Celluloid.logger.tap { |l| l.level = ::Logger::INFO unless debug }
    @sensor         = options[:track_sensor] || DerbyConfig.sensor_class.new(device_glob: DerbyConfig.device_glob, logger: @logger)
    @sensor_state   = options[:sensor_state] || SensorState
    @heat           = options[:heat]         || Heat
    @faye           = options[:faye]         || Faye
    @announcer      = options[:announcer]    || AnnounceController
    initialize_state
    subscribe('race results', :record_race_results)
    @logger.info "Sensor watch started w/ device search path: #{@sensor.device_glob.inspect}"
  end

  def record_race_results(_, results)
    self.state = :idle
    @heat.post_results results
  end

  def start_race
    @logger.debug 'Sensor: Starting a race'
    self.state = :active
    @sensor.new_race

    self
  end

  def quit
    @sensor.close

    self
  end

private

  def initialize_state
    if @heat.current.any?
      start_race
    else
      self.state = :idle
    end
  end

  def state=(state)
    return if @state == state
    @state = state
    write_state
  end

  def write_state
    @sensor_state.update @state
  end

  def active?
    @state == :active
  end

  def idle?
    @state == :idle
  end

  def unplugged?
    @state == :unplugged
  end
end
