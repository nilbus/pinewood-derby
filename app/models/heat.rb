class Heat < ActiveRecord::Base
  has_many :runs, dependent: :destroy
  has_many :contestants, through: :runs

  scope :current, -> { where(status: 'current') }
  scope :complete, -> { where(status: 'complete').order('sequence DESC, created_at DESC').includes(runs: :contestant) }
  scope :most_recent, -> { complete.limit(1) }
  scope :upcoming, -> { where(status: 'upcoming').order('sequence, created_at').includes(runs: :contestant) }
  scope :upcoming_incomplete, -> { where(status: 'upcoming').joins(:runs).group('heats.id').having('count(runs.id) < ?', DerbyConfig.lane_count) }

  validates :status,   presence: true, inclusion: {in: %w(upcoming current complete)}
  validates :sequence, presence: true

  class << self
    def fill_lineup(options = {})
      upcoming_incomplete.readonly(false).destroy_all
      races_to_queue = options.fetch(:races, 3)
      contestants_per_heat = DerbyConfig.lane_count
      races_to_queue.times do
        break if upcoming.count >= races_to_queue
        chosen_contestants = {}
        contestants_per_heat.times do |i|
          lane = i + 1
          next_contestant = Contestant.next_suitable(lane: lane, exclude: chosen_contestants.values)
          next unless next_contestant
          chosen_contestants[lane] = next_contestant
        end
        break if chosen_contestants.none?
        Heat.create_upcoming_from_contestants chosen_contestants
      end
    end

    def create_upcoming_from_contestants(contestants_by_lane)
      transaction do
        heat = Heat.create! sequence: next_sequence, status: 'upcoming'
        contestants_by_lane.each do |lane, contestant|
          heat.runs.create! contestant: contestant, lane: lane
        end

        heat
      end
    end

    def post_results(results)
      heat = current.first
      return unless heat
      heat.add_run_times(results)
      heat.complete!
    end

    def create_practice(options = {})
      Heat.transaction do
        raise Notice.new "There's already a race going" if Heat.current.any?
        contestants = options[:contestants] || Contestant.limit(DerbyConfig.lane_count)
        raise Notice.new "Add contestants first" if contestants.none?
        heat = create! sequence: -1, status: 'current'
        contestants.each_with_index do |contestant, i|
          lane = i + 1
          Run.create! contestant: contestant, heat: heat, lane: lane
        end

        heat
      end
    end

    def next_sequence
      Heat.order('sequence DESC').limit(1).pluck(:sequence).first || 1
    end
  end

  def start(options = {})
    update_attributes status: 'current' if Heat.current.count == 0
    raise "Can't start; there's already a heat running" unless current?
    options.fetch(:sensor_watch, SensorWatch).start_race

    true
  end

  def add_run_times(results)
    runs_by_lane = runs.group_by(&:lane)
    results.each do |result|
      run = runs_by_lane[result[:track].to_i].try :first
      run.set_time result[:time] if run
    end
  end

  def complete!
    update_attributes! status: 'complete'
  end

  def cancel!
    return false unless status == 'current'
    update_attributes! status: 'upcoming'
  end

  def current?
    status == 'current'
  end

  def upcoming?
    status == 'upcoming'
  end
end
