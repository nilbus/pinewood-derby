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

  def average_time
    average_time = self[:average_time] || calculate_average_time

    average_time.try :round, 3
  end

private

  def calculate_average_time
    self.class.ranked.where(id: id).first.try :average_time
  end

end
