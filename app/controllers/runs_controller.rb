class RunsController < ApplicationController
  def postpone
    Run.find(params[:id]).postpone
    redirect_to board_path
  end
end
