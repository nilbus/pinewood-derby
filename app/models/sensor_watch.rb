# Tracks the sensor and race state.
# The SensorWatch daemon instantiates this class to
# keep a persistent connection to the TrackSensor
# and regularly probe the sensor for updates (tick).
#
# SensorWatch does not return state or results directly;
# instead it updates SensorState, Heat, and Run database records,
# so Observers can take care of the updates.
#
class SensorWatch
  def self.start_race
    Process.kill('USR1', daemon_pid)
  end

  def initialize(options = {})
    @sensor         = options[:track_sensor] || TrackSensor.new
    @sensor_state   = options[:sensor_state] || SensorState
    @heat           = options[:heat]         || Heat
    @run            = options[:run]          || Run
    @faye           = options[:faye]         || Faye
    @announcer      = options[:announcer]    || AnnounceController
    @logger         = options[:logger]       || ApplicationHelper
    @faye.ensure_reactor_running!
    @state = :idle
    if @heat.current.any?
      start_race
    else
      clear_buffer
    end
  end

  def start_race
    @logger.log 'Sensor: Starting a race'
    clear_buffer
    self.state = :active
    @sensor.new_race

    self
  rescue IOError
    self.state = :unplugged

    nil
  end

  def tick
    update_state

    self
  end

  def cancel_heat
    :not_implemented
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
    @sensor_state.update @state
  end

  def clear_buffer
    while check_for_results do
    end
  end

  def update_state
    check_for_results # triggers an unplugged state change if unplugged
  end

  def check_for_results
    results = @sensor.race_results
    if results
      self.state = :idle
      post_results results
    end

    results
  rescue IOError
    self.state = :unplugged

    nil
  end

  def post_results(results)
    heat = @heat.current.first
    return unless heat
    add_run_times heat, results
    heat.complete!
  end

  def add_run_times(heat, results)
    runs = heat.runs.group_by(&:lane)
    results.each do |result|
      run = runs[result[:lane].to_i].first
      run.set_time result[:time]
    end
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
