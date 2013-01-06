class Heat < ActiveRecord::Base
  has_many :runs

  def complete!
    update_attribute :status, 'completed'
  end
end
