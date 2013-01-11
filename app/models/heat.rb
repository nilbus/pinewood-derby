class Heat < ActiveRecord::Base
  has_many :runs, dependent: :destroy
  has_many :contestants, through: :runs

  scope :current, -> { where(status: 'current') }
  scope :most_recent, -> { where(status: 'complete').order('created_at DESC').includes(runs: :contestant).limit(1) }
  scope :upcoming, -> { where(status: 'upcoming').order('sequence, created_at').includes(run: :contestant) }

  validates :status,   presence: true, inclusion: {in: %w(upcoming current complete)}
  validates :sequence, presence: true

  def self.create_practice(options = {})
    Heat.transaction do
      raise Notice.new "There's already a race going" if Heat.current.any?
      contestants = options[:contestants] || Contestant.limit(3)
      raise Notice.new "Add contestants first" if contestants.none?
      heat = create! sequence: -1, status: 'current'
      contestants.each_with_index do |contestant, i|
        lane = i + 1
        Run.create! contestant: contestant, heat: heat, lane: lane
      end

      heat
    end
  end

  def start(options = {})
    raise 'You can only start the current Heat' unless current?
    options.fetch(:sensor_watch, SensorWatch).start_race

    true
  end

  def complete!
    update_attributes! status: 'complete'
  end

  def current?
    status == 'current'
  end
end
