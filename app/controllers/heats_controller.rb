class HeatsController < ApplicationController
  before_filter :require_admin

  def cancel_current
    current_heat = Heat.current.first
    success = !!current_heat.try(:cancel!)
    SensorState.update :canceled
    render json: Dashboard.to_json
  end
end
