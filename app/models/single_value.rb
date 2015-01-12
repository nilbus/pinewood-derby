class SingleValue < ActiveRecord::Base
  @@mutex = Mutex.new

  def self.update(value)
    subclass_name = self.name
    single_value = nil
    @@mutex.synchronize do
      single_value = SingleValue.find_or_create_by(type: subclass_name)
    end
    single_value.update_attribute :value, Marshal.dump(value)

    single_value
  end

  def self.get(options = {})
    subclass_name = self.name
    scope = where(type: subclass_name)
    scope = scope.where("updated_at >= ?", options[:newer_than]) if options[:newer_than].present?
    result = scope.first
    return if result.nil?
    value = Marshal.load(result.value)

    HashWithIndifferentAccess[value] if value
  end
end
