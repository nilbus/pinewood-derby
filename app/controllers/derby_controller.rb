class DerbyController < ApplicationController
  before_filter :ignore_if_password_not_set, only: [:login, :authenticate]
  before_filter :require_admin, except: [:login, :authenticate]

  def login
    session[:admin] = false # implicit logout
  end

  def authenticate
    if params[:password] == DerbyConfig.admin_password
      session[:admin] = true
      redirect_to contestants_path
    else
      redirect_to login_derby_path
    end
  end

  def reset
    Contestant.destroy_all
    Heat.destroy_all
    SensorState.update :idle
    redirect_to contestants_path
  end

protected

  def ignore_if_password_not_set
    redirect_to root_path unless DerbyConfig.admin_password
  end
end
