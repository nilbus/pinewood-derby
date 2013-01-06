class Run < ActiveRecord::Base
  def set_time(time)
    update_attribute :time, time
  end
end
