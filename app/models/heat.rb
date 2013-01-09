class Heat < ActiveRecord::Base
  has_many :runs
  has_many :contestants, through: :runs

  scope :current, -> { where(status: 'current').first }
  scope :most_recent, -> { where(status: 'complete').order('sequence DESC').includes(runs: :contestant).limit(1) }
  scope :upcoming, -> { where(status: 'upcoming').order('sequence, created_at').includes(run: :contestant) }

  def complete!
    update_attribute :status, 'completed'
  end
end
