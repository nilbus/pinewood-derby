class RaceManager
  attr_reader :current_heat

  def initialize(options = {})
    @max_restart_attempts = options[:max_restart_attempts] || 5
    @current_heat = nil
    @heat_start_time = nil
  end

  # States: :idle, :active, :unplugged, :unknown
  def sensor_state
    start_time = Time.now
    SensorWatch.update_state

    return busy_wait_for(:timeout => 2) do
      SensorState.get(newer_than: start_time)
    end
  rescue Timeout::Error
    :unknown
  end

  def start_heat(heat, options = {})
    if @current_heat && !options[:restart]
      raise StateError.new "There is already a heat in progress: #{@current_heat}"
    end
    limit_consecutive_restarts(options)
    @current_heat = heat
    @heat_start_time = Time.now
    SensorWatch.start_race
  end

  # @return [Boolean] Are they here yet?
  def check_for_scores
    if @current_heat.nil?
      if @heat_start_time
        return true
      else
        raise StateError.new 'No heat has been started yet'
      end
    end
    if (scores = LatestScores.get(newer_than: @heat_start_time))
      add_run_times scores
      mark_heat_completed
      @current_heat = nil
      return true
    else
      case sensor_state
      when :active then return false
      when :idle then start_heat(@current_heat, restart: true) # perhaps recovering from unplug or power cycle
      when :unplugged then raise StateError.new 'The sensor is unplugged'
      when :unknown then raise StateError.new 'Could not get the status from the sensor; try restarting?'
      end
    end
  end

  def cancel_heat
    raise NotImplementedError
  end

private

  def add_run_times(scores)
    runs = @current_heat.runs.group_by(&:lane)
    raise StateError.new "Multiple contestants in one lane: #{runs.map { |run| {contestant: run.contestant, lane: run.lane} }}" if runs.values.any? { |in_lane| in_lane.many? }
    raise StateError.new 'There were more contestants than tracks reported by the sensor.' if runs.size > scores.size
    scores.each_with_index do |score, i|
      run = runs[score[:lane].to_i].first
      run.set_time score[:time]
    end
  end

  def mark_heat_completed
    @current_heat.complete!
  end

  # Busy-wait until the block returns a truthy value.
  # Check every [:interval] seconds (default 0.1).
  # Optionally time out after [:timeout] seconds (default Infinity).
  #
  # @returns yield return value
  # @throws [Timeout::Error]
  #
  def busy_wait_for(options = {})
    interval = options[:interval] || 0.1
    return Timeout::timeout(options[:timeout]) do
      sleep interval until (retval = yield)

      retval
    end
  end

  def limit_consecutive_restarts(options)
    @restart_attempts ||= 0
    if options[:restart]
      if (@restart_attempts += 1) >= @max_restart_attempts
        @current_heat = @heat_start_time = nil
        raise StateError.new "The sensor would not start a race after #{@restart_attempts} attempts."
      end
    else
      @restart_attempts = 0
    end
  end

  class StateError < RuntimeError; end
end
