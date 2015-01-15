class AnnounceController < FayeRails::Controller
  def self.update
    return unless FayeRails.servers.any?
    Heat.fill_lineup
    publish '/announce', Dashboard.to_json
  end

  def self.derby_begin
    publish '/announce', {derby_status: 'begin'}.to_json
  end

  def self.derby_complete
    publish '/announce', {derby_status: 'complete'}.to_json
  end

  faye = self

  observe Contestant, :after_create do |contestant|
    Heat.upcoming[1..-1].try :each, &:destroy
  end

  observe Contestant, :after_save do |contestant|
    ApplicationHelper.log "Announcing contestant save"
    faye.update
  end

  observe Heat, :after_update do |heat|
    if heat.status.to_sym == :current && Heat.complete.count.zero?
      faye.derby_begin
    elsif heat.status.to_sym == :complete && Heat.upcoming.count.zero?
      faye.derby_complete
    end
  end

  observe Derby, :after_save do |derby|
    ApplicationHelper.log "Announcing derby save"
    faye.update
  end

  observe SensorState, :after_save do |derby|
    ApplicationHelper.log "Announcing SensorState update"
    faye.update
  end

  # channel '/announce' do
  #   monitor :publish do
  #     ApplicationHelper.log "Client #{client_id} published #{data.inspect} to #{channel}."
  #   end
  # end
end
