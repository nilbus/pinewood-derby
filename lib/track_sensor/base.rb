# An abstract driver for SerialPort based track sensors.
# Uses Celluloid::Notifications to publish on topics:
#   - 'race results' (see #handle_device_input)
#   - 'device change'
class TrackSensor::Base
  include Celluloid
  include Celluloid::IO
  include Celluloid::Notifications

  SERIAL_DEFAULTS = {'baud' => 9600, 'data_bits' => 8, 'stop_bits' => 1, 'parity' => ::SerialPort::NONE}
  POLL_DEVICES_PERIOD_SECONDS = 5

  attr_accessor :device_glob

  trap_exit :device_failed

  def initialize(options = {})
    @device_glob = ENV['TRACK_SENSOR_DEVICE'] || options[:device_glob] || '/dev/tty{USB,.usbserial}*'
    @devices = []
    @data = {}
    @logger = options[:logger] || Celluloid.logger
    subscribe('serial device line', :handle_device_input)
    initialize_new_devices
    debug "Devices found: #{@devices.map(&:path)}"
  end

  def run
    scan_for_device_changes
    every(POLL_DEVICES_PERIOD_SECONDS) do
      async.scan_for_device_changes
    end
  end

  # As they occur, publish [Array<Hash>, nil] Race times
  # on channel "race results" in the format:
  #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
  def handle_device_input(_, line)
    return debug "Ignoring non-time data: #{line}" unless line =~ times_regex
    debug "Read times: #{line}"
    times = parse_times line
    publish 'race results', times
  end

  def new_race
    raise NotImplementedError
  end

  def plugged_in?
    scan_for_device_changes
    @devices.any?
  end

  def close
    @devices.each &:close
    @devices.clear
  end

protected

  # Write to the serial devices.
  # Try to communicate with all device files that match the device_glob option to {#initialize}.
  # If the write raises an exception, it will crash the SerialDevice actor.
  # @yield [device] IO object to read from and write to
  def write(data)
    scan_for_device_changes
    @devices.each do |device|
      device.async.write(data)
    end
  end

private

  def initialize_device(device_path)
    return false unless File.writable? device_path
    debug "Initializing #{device_path} with serial params #{serial_params.inspect}"

    params = serial_params.stringify_keys.reverse_merge(SERIAL_DEFAULTS)
    device = SerialDevice.new(device_path, params)
    link device
    publish 'device change'
    device
  end

  def scan_for_device_changes
    initialize_new_devices
  end

  def initialize_new_devices
    available_device_paths = Dir.glob(@device_glob)
    new_device_paths = available_device_paths - @devices.map(&:path)
    new_device_paths.each do |new_device_path|
      if (device = initialize_device(new_device_path))
        debug "New device: #{new_device_path.inspect}"
        @devices << device
      end
    end
  end

  def device_failed(device, reason)
    debug "Removing failed device. #{reason}"
    @devices.delete(device)
    publish 'device change' if Celluloid::Actor[:notifications_fanout]
  end

  def debug(message)
    @logger.debug message
  end
end
