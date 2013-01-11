class RacesController < ApplicationController
  def index
    
  end

  def new
    Heat.create_practice.start
    redirect_to races_path, notice: 'Race started'
  rescue Notice => e
    redirect_to races_path, alert: e.message
  rescue RuntimeError => e
    redirect_to races_path, alert: "#{e.inspect}: #{e.message}"
  end
end
