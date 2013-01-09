class AnnounceController < FayeRails::Controller
  faye = self

  observe Run, :after_update do |run|
    faye.publish '/announce', run.attributes
  end

  observe Heat, :after_update do |heat|
    faye.publish '/announce', heat.attributes
  end

  observe SensorState, :after_update do |sensor_state|
    faye.publish '/announce', sensor_state.attributes
  end

  observe Derby, :after_update do |derby|
    faye.publish '/announce', derby.attributes
  end
end
