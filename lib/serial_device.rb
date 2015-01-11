# A serial port device interface to a SerialPort.
# Write using #write.
# A SerialDevice immediately attempts to read, and uses
# Celluloid::Notifications to publish the topic "serial device line" for each
# line read.
# Close with #close to stop reading.
class SerialDevice
  include Celluloid
  include Celluloid::IO
  include Celluloid::Notifications

  attr_accessor :path

  def initialize(device_path, *args)
    @path = device_path
    @port = SerialPort.new device_path, *args
    async.monitor
  end

  def write(data)
    @port.write(data)
    @port.flush
  end

  def close
    @port.close
    terminate
  end

private

  def monitor
    @port.each_line do |line|
      publish 'serial device line', line
    end
    terminate
  end
end
