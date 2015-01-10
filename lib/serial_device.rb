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
