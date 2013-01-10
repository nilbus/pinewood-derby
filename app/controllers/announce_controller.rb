class AnnounceController < FayeRails::Controller
  faye = self

  observe Run, :after_update do |run|
    ApplicationHelper.log "Announcing run change"
    faye.publish '/announce', Dashboard.to_json
  end

  observe Heat, :after_update do |heat|
    ApplicationHelper.log "Announcing heat change"
    faye.publish '/announce', Dashboard.to_json
  end

  observe SensorState, :after_update do |sensor_state|
    ApplicationHelper.log "Announcing sensor_state change"
    faye.publish '/announce', Dashboard.to_json
  end

  observe Derby, :after_update do |derby|
    ApplicationHelper.log "Announcing derby change"
    faye.publish '/announce', Dashboard.to_json
  end

  channel '/announce' do
    monitor :publish do
      ApplicationHelper.log "Client #{client_id} published #{data.inspect} to #{channel}."
    end
  end
end
