module ApplicationHelper
  def self.log(message, level = :info)
    Rails.logger.send level, message
    Rails.logger.flush
  end
end
