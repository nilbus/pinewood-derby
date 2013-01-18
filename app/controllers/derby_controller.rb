class DerbyController < ApplicationController
  def reset
    Contestant.destroy_all
    Heat.destroy_all
    redirect_to contestants_path
  end
end
