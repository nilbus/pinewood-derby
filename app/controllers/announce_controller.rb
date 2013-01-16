class AnnounceController < FayeRails::Controller
  def self.update
    Heat.fill_lineup
    publish '/announce', Dashboard.to_json
  end

  faye = self

  observe Contestant, :after_save do |contestant|
    ApplicationHelper.log "Announcing contestant change"
    faye.update
  end

  observe Run, :after_update do |run|
    ApplicationHelper.log "Announcing run change"
    faye.update
  end

  observe Heat, :after_update do |heat|
    ApplicationHelper.log "Announcing heat change"
    faye.update
  end

  observe SensorState, :after_save do |sensor_state|
    ApplicationHelper.log "Announcing sensor_state change"
    faye.update
  end

  observe Derby, :after_save do |derby|
    ApplicationHelper.log "Announcing derby change"
    faye.update
  end

  # channel '/announce' do
  #   monitor :publish do
  #     ApplicationHelper.log "Client #{client_id} published #{data.inspect} to #{channel}."
  #   end
  # end
end
