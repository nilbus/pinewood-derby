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
    check_daemon && Process.kill('USR1', daemon_pid)
  rescue Errno::ESRCH
  end

  def self.check_daemon
    Process.kill(0, daemon_pid)

    true
  rescue Errno::ESRCH
    SensorState.update :daemon_died

    false
  end

  def initialize(options = {})
    @sensor         = options[:track_sensor] || DerbyConfig.sensor_class.new
    @sensor_state   = options[:sensor_state] || SensorState
    @heat           = options[:heat]         || Heat
    @run            = options[:run]          || Run
    @faye           = options[:faye]         || Faye
    @announcer      = options[:announcer]    || AnnounceController
    @logger         = options[:logger]       || ApplicationHelper
    @faye.ensure_reactor_running!
    initialize_state
    @announcer.update
  end

  def start_race
    @logger.log 'Sensor: Starting a race'
    clear_buffer
    self.state = :active
    trigger_race_start

    self
  end

  def tick
    trigger_race_start if active?
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

  def self.daemon_pid_filename
    Rails.root.join 'log/sensor_watch.rb.pid'
  end

  def self.daemon_pid
    File.read(daemon_pid_filename).strip.to_i
  rescue Errno::ENOENT
    raise Errno::ESRCH
  end

  def initialize_state
    if @heat.current.any?
      start_race
    else
      self.state = :idle
      clear_buffer
    end
  end

  def trigger_race_start
    @sensor.new_race
  rescue IOError
    self.state = :unplugged
  end

  def state=(state)
    return if @state == state
    @state = state
    write_state
  end

  def write_state
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
    initialize_state if unplugged? # No longer unplugged if we got here without error

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
      run = runs[result[:track].to_i].try :first
      run.set_time result[:time] if run
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
