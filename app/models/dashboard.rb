class Dashboard
  def self.to_json
    new.to_json
  end

  def to_json
    {
      contestant_times: contestant_times,
      most_recent_heat: most_recent_heat,
      upcoming_heats: upcoming_heats,
      notice: notice,
      device_status: device_status
    }.to_json
  end

private

  def contestant_times
    rank = 0
    Contestant.ranked.map do |contestant|
      rank += 1

      {
        rank: rank,
        name: contestant.name,
        average_time: contestant.average_time
      }
    end
  end

  def most_recent_heat
    heat = Heat.most_recent.first
    return unless heat

    heat.runs.map do |run|
      {
        name: run.contestant.name,
        time: run.time
      }
    end
  end

  def upcoming_heats
    Heat.upcoming.limit(3).map do |heat|
      {
        contestants: heat.run.map do |run|
          {
            name: run.contestant.name,
            lane: run.lane
          }
        end
      }
    end
  end

  def notice
    derby_notice = (Derby.get || {})[:notice]
    unplugged_notice = 'The sensor is unplugged!' if SensorState.get == :unplugged

    unplugged_notice || derby_notice
  end

  def device_status
    SensorState.get
  end
end
