class Heat < ActiveRecord::Base
  has_many :runs

  scope :current, -> { where(status: 'current').first }

  def complete!
    update_attribute :status, 'completed'
  end
end
