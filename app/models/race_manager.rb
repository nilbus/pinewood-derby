# Validates proper race conditions for starting heats.
# The Rails app interacts with RaceManager instead of SensorWatch,
# because SensorWatch lives in a different process
# and cannot raise exceptions
module RaceManager
  class << self
    # @throws [RaceManager::StateError] if there is no valid heat to start
    def start_heat
      validate_heat_ready!
      SensorWatch.start_race

      self
    end

  private

    def validate_heat_ready!
      heat = Heat.current
      raise StateError.new 'There is no heat marked as current.' unless heat
      runs = heat.runs.group_by(&:lane)
      raise StateError.new "Multiple contestants in one lane: #{runs.map { |run| {contestant: run.contestant, lane: run.lane} }}" if runs.values.any? { |in_lane| in_lane.many? }
    end

    class StateError < RuntimeError; end
  end
end
