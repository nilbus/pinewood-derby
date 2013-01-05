class BoardController < ActionController::Base
  def welcome
    @url = BoardHelper.app_url(request)
  end

  def status_board
  end
end
