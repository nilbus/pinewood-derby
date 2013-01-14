class RacesController < ApplicationController
  def index
  end

  def new
    heat = case params[:type]
      when 'practice' then Heat.create_practice
      else Heat.upcoming.try :first
      end
    heat.try :start
    respond_to do |format|
      format.html { redirect_to races_path, notice: 'Race started' }
      format.js { render js: '' }
    end
  rescue Notice => e
    redirect_to races_path, alert: e.message
  rescue RuntimeError => e
    respond_to do |format|
      format.html { redirect_to races_path, alert: "#{e.class}: #{e.message}" }
      format.js { render js: "alert('#{e.class}: #{e.message}');" }
    end
  end
end
