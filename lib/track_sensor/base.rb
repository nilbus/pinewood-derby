class TrackSensor::Base
  include Celluloid
  include Celluloid::IO
  include Celluloid::Notifications

  SERIAL_DEFAULTS = {'baud' => 9600, 'data_bits' => 8, 'stop_bits' => 1, 'parity' => ::SerialPort::NONE}
  POLL_DEVICES_PERIOD_SECONDS = 5

  attr_accessor :device_glob

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

  def close
    @devices.each &:close
    @devices.clear
  end

protected

private

  def initialize_device(device_path)
    return false unless File.writable? device_path
    debug "Initializing #{device_path} with serial params #{serial_params.inspect}"

    params = serial_params.stringify_keys.reverse_merge(SERIAL_DEFAULTS)
    SerialDevice.new(device_path, params)
  end

  def scan_for_device_changes
    initialize_new_devices
    # raise IOError.new('The sensor is not plugged in') unless plugged_in?
  end

  def plugged_in?
    scan_for_device_changes

    @devices.any?
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

  def debug(message)
    @logger.debug message
  end
end
