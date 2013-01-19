class DerbyController < ApplicationController
  def reset
    Contestant.destroy_all
    Heat.destroy_all
    SensorState.update :idle
    redirect_to contestants_path
  end
end
