# States: :idle, :active, :unplugged
class SensorState < SingleValue
  def self.update(state)
    super state: state
  end

  def self.get(options = {})
    (super || {})[:state].try :to_sym
  end
end
