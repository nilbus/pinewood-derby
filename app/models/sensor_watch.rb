# Tracks the sensor and race state.
# The SensorWatch daemon instantiates this class to
# keep a persistent connection to the TrackSensor
# and regularly probe the sensor for updates (tick).
#
# This class does not return state or scores directly;
# instead it updates SensorState and LatestResults via #update.
#
# States:
#   idle      - the sensor is on, and the start race trigger is deactivated
#   active    - the start race trigger is activated; waiting for results
#   unplugged - the sensor is reporting to be unplugged
#
class SensorWatch
  def self.start_race
    Signal.kill('USR1', daemon_pid)
  end

  def initialize(options = {})
    @sensor         = options[:track_sensor] || TrackSensor.new
    @sensor_state   = options[:sensor_state] || SensorState
    @latest_results = options[:latest_results] || LatestResults
    @state = :idle
    clear_buffer
  end

  def start_race
    clear_buffer
    self.state = :active
    @sensor.new_race

    self
  end

  def tick
    update_state

    self
  end

  def quit
    @sensor.close

    self
  end

private

  def self.daemon_pid
    File.read('log/sensor_watch.rb.pid').strip.to_i
  end

  def state=(state)
    return if @state == state
    @state = state
  end

  def clear_buffer
    while check_for_scores do
    end
  end

  def update_state
    initial_state = @state
    check_for_scores # triggers an unplugged state change if unplugged
    @sensor_state.update @state unless @state == initial_state

    self
  end

  def check_for_scores
    results = @sensor.race_results
    if results
      self.state = :idle
      post_results results
    end

    results
  rescue
    self.state = :unplugged
  end

  def post_results(results)
    @latest_results.update results
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
