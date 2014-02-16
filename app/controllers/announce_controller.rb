class AnnounceController < FayeRails::Controller
  def self.update
    Heat.fill_lineup
    publish '/announce', Dashboard.to_json
  end

  faye = self

  observe Contestant, :after_create do |contestant|
    Heat.upcoming[1..-1].try :each, &:destroy
  end

  observe Contestant, :after_save do |contestant|
    ApplicationHelper.log "Announcing contestant save"
    faye.update
  end

  observe Run, :after_update do |run|
    ApplicationHelper.log "Announcing run save"
    faye.update
  end

  observe Heat, :after_update do |heat|
    ApplicationHelper.log "Announcing heat save"
    faye.update
  end

  observe Derby, :after_save do |derby|
    ApplicationHelper.log "Announcing derby save"
    faye.update
  end

  # channel '/announce' do
  #   monitor :publish do
  #     ApplicationHelper.log "Client #{client_id} published #{data.inspect} to #{channel}."
  #   end
  # end
end
