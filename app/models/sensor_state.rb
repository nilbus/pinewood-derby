# States:
#   idle      - the sensor is on, and the start race trigger is deactivated
#   active    - waiting for start race trigger and light sensors to be triggered
#   unplugged - the sensor is reporting to be unplugged
#
class SensorState < SingleValue
  def self.update(state)
    super state: state
  end

  def self.get(options = {})
    (super || {})[:state].try :to_sym
  end
end
