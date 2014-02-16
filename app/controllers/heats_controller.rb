class HeatsController < ApplicationController
  def cancel_current
    return render json: {canceled: false}, status: 403 unless admin?
    current_heat = Heat.current.first
    success = !!current_heat.try(:cancel!)

    render json: {canceled: success}
  end
end
