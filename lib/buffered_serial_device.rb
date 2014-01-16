require 'serialport'
require 'iobuffer'

class BufferedSerialDevice
  attr_reader :path

  def initialize(device_path, serial_params)
    @path = device_path
    @serial_port = SerialPort.new device_path, serial_params
    @buffer = IO::Buffer.new
  end

  def readline
    @buffer.read_from @serial_port
    buffer_content = @buffer.read
    line, newline, remaining = buffer_content.partition("\n")
    if (no_newline_found = newline.empty?)
      remaining = line
      raise Errno::EAGAIN
    end

    line + newline
  ensure
    @buffer.prepend remaining.to_s
  end

  def write(data)
    @serial_port.write_nonblock data
    @serial_port.flush
  end

  def close
    @serial_port.close
  end
end
