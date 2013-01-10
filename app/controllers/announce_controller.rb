class AnnounceController < FayeRails::Controller
  faye = self

  observe Run, :after_update do |run|
    faye.publish '/announce', run.attributes
    ApplicationHelper.log "Announcing run change"
  end

  observe Heat, :after_update do |heat|
    faye.publish '/announce', heat.attributes
    ApplicationHelper.log "Announcing heat change"
  end

  observe SensorState, :after_update do |sensor_state|
    faye.publish '/announce', sensor_state.attributes
    ApplicationHelper.log "Announcing sensor_state change"
  end

  observe Derby, :after_update do |derby|
    faye.publish '/announce', derby.attributes
    ApplicationHelper.log "Announcing derby change"
  end

  channel '/announce' do
    monitor :publish do
      ApplicationHelper.log "Client #{client_id} published #{data.inspect} to #{channel}."
    end
  end
end
