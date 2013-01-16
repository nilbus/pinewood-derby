class Contestant < ActiveRecord::Base
  has_many :runs, dependent: :destroy
  has_many :heats, through: :runs

  scope :ranked, -> do
    select('contestants.*, avg(runs.time) AS average_time').
    joins(:runs => :heat).
    where('heats.sequence >= 0').
    group('contestants.id').
    order('average_time')
  end

  def self.next_suitable(options = {})
    exclude = Array(options[:exclude])
    exclude = [Contestant.new] if exclude.empty?
    exclude = exclude.map { |contestant| contestant.id.to_i }
    lane = options[:lane].to_i
    max_runs_per_contestant = 3

    # select
    s = select('contestants.*')
    # filter
    s = s.where('contestants.id NOT IN (?)', exclude) if exclude.any?
    s = s.where('contestants.retired IS NOT TRUE')
    s = s.group('contestants.id')
    s = s.joins('LEFT JOIN runs ON runs.contestant_id = contestants.id')
    s = s.having('count(DISTINCT heats.id) < ?', max_runs_per_contestant)
    s = s.joins("LEFT JOIN runs AS runs_in_lane ON runs.contestant_id = contestants.id AND runs.lane = #{lane}")
    s = s.having("count(runs_in_lane.id) = 0")
    # order
    s = s.joins('LEFT JOIN heats ON heats.id = runs.heat_id')
    s = s.joins("LEFT JOIN runs AS runs_with_chosen ON runs_with_chosen.heat_id = heats.id AND runs_with_chosen.contestant_id IN (#{exclude.join(',')})")
    s = s.select('count(runs_with_chosen.id) AS heat_count_with_chosen')
    s = s.select('count(DISTINCT heats.id) AS heat_count')
    s = s.select('avg(runs.time) AS average_run_time')
    s = s.order('heat_count_with_chosen, heat_count, average_run_time DESC, contestants.created_at')

    return s if options[:raw]
    s.first
  end

  def average_time
    average_time = self[:average_time] || calculate_average_time

    average_time.try :round, 3
  end

private

  def calculate_average_time
    (self.class.ranked.where(id: id).first || {})[:average_time]
  end

end
