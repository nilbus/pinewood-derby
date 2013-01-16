require 'track_sensor'

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
    Contestant.ranked.keep_if(&:average_time).map do |contestant|
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
    return [] unless heat

    heat.runs.map do |run|
      {
        name: run.contestant.name,
        time: run.time,
        lane: run.lane
      }
    end
  end

  def upcoming_heats
    heats = (Heat.current + Heat.upcoming.limit(3))[0,3]
    heats.map do |heat|
      {
        current: heat.status == 'current',
        contestants: heat.runs.map do |run|
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
    warning_notice = case SensorState.get
    when :unplugged then 'The sensor is unplugged'
    when :daemon_died then 'The sensor monitor is not running'
    end

    warning_notice || derby_notice
  end

  def device_status
    SensorState.get
  end
end
