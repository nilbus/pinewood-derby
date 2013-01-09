class Contestant < ActiveRecord::Base
  has_many :runs, dependent: :destroy
  has_many :heats, through: :runs

  scope :ranked, -> { joins(:runs).select('contestants.*, avg(runs.time) AS average_time').group('contestants.id').order('average_time') }
end
