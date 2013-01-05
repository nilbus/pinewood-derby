class BoardController < ApplicationController
  def welcome
    @url = BoardHelper.app_url(request)
  end

  def status_board
  end
end
