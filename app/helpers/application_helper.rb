module ApplicationHelper
  def self.log(message, level = :info)
    Rails.logger.send level, message
    Rails.logger.flush
  end

  def admin?
    if DerbyConfig.admin_password
      session['admin']
    else
      true
    end
  end
end
