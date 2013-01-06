class SingleValue < ActiveRecord::Base
  def self.update(value)
    single_value = SingleValue.find_or_create_by(type: self.name)
    single_value.update_attribute :value, value

    single_value
  end

  def self.get(options = {})
    scope = self
    scope = scope.where("updated_at >= ?", options[:newer_than]) if options[:newer_than].present?
    value = scope.first.try(:value)

    HashWithIndifferentAccess[value] if value
  end
end
