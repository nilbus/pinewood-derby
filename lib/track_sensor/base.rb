class TrackSensor::Base
  include Celluloid
  include Celluloid::IO
  include Celluloid::Notifications

  attr_accessor :device_glob

  def initialize(options = {})
    @device_glob = ENV['TRACK_SENSOR_DEVICE'] || options[:device_glob] || '/dev/tty{USB,.usbserial}*'
    @devices = []
    @data = {}
    @logger = options[:logger] || Celluloid.logger
    initialize_new_devices
    debug "Devices found: #{@devices.map(&:path)}"
  end

  def race_results
    raise NotImplementedError
  end

  def new_race
    raise NotImplementedError
  end

  def close
    @devices.each &:close
    @devices.clear
  end

protected

  # Communicate with the serial device.
  # Try to communicate with all device files that match the device_glob option to {#initialize}.
  # IO errors that occur while reading or writing to a device cause the device to be temporarily
  # ignored until the next call to this method.
  # The block should use blocking IO.
  # @yield [device] IO object to read from and write to
  # @raise [IOError] if no device is available for use
  def communicate
    scan_for_device_changes do |failed_devices|
      @devices.each do |device|
        begin
          yield device
        rescue IOError, Errno::ENXIO, Errno::EIO
          debug "Failed device #{device.path}"
          failed_devices << device
        end
      end
    end
  end

private

  def initialize_device(device_path)
    return false unless File.writable? device_path
    debug "Initializing #{device_path} with serial params #{serial_params.inspect}"
    device = SerialPort.new device_path, serial_params.stringify_keys.reverse_merge('baud' => 9600, 'data_bits' => 8, 'stop_bits' => 1, 'parity' => ::SerialPort::NONE)
    device.class_eval { define_method(:path) { device_path } }

    device
  end

  def scan_for_device_changes
    failed_devices = []
    initialize_new_devices
    yield failed_devices
  ensure
    @devices -= failed_devices
    raise IOError.new('The sensor is not plugged in') unless plugged_in?
  end

  def plugged_in?
    initialize_new_devices

    @devices.any?
  end

  def initialize_new_devices
    available_device_paths = Dir.glob(@device_glob)
    new_device_paths = available_device_paths - @devices.map(&:path)
    new_device_paths.each do |new_device_path|
      device = initialize_device(new_device_path)
      debug "New device: #{new_device_path.inspect}" if device
      @devices << device if device
    end
  end

  def debug(message)
    @logger.debug message
  end
end
