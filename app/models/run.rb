class Run < ActiveRecord::Base
  belongs_to :contestant
  belongs_to :heat

  def set_time(time)
    update_attribute :time, time
  end
end
