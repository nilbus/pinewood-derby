class RunsController < ApplicationController
  before_filter :require_admin

  def postpone
    Run.find(params[:id]).postpone
    redirect_to board_path
  end
end
