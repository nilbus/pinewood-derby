class RacesController < ApplicationController
  def index
    
  end

  def new
    Heat.create_practice.start
    redirect_to races_path, notice: 'Race started'
  end
end
