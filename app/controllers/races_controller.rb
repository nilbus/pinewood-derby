class RacesController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper

  before_filter :require_admin

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
      format.html { redirect_to races_path, alert: "#{e.class}: #{j e.message}" }
      format.js { render js: "console.log('#{e.class}: #{j e.message}');" }
    end
  end

  def redo
    Heat.transaction do
      heat = Heat.most_recent.first
      heat.runs.each { |run| run.update_attributes time: nil }
      heat.start
    end

    render js: ''
  rescue RuntimeError => e
    render js: "console.log('#{e.class}: #{j e.message}');"
  end
end
