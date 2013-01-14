class TrackSensor
  def initialize(options = {})
    @device_glob = options[:device_glob] || '/dev*/ttyUSB*'
    @devices = []
    @data = {}
    initialize_new_devices
  end

  # @return [Array<Hash>, nil] Race times, if any, in the format:
  #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
  # @raise [IOError] if the device is not plugged in
  def race_results
    scan_for_device_changes do |failed_devices|
      @devices.each do |device|
        begin
          char = device.read_nonblock(1)
          return race_results if char == "\000"
          line = char + device.readline
          return race_results if line =~ /DT.000  NewBold Products/
          return parse_times line
        rescue Errno::EAGAIN
        rescue IOError
          failed_devices << device
        end
      end

      nil
    end
  end

  def new_race
    scan_for_device_changes do |failed_devices|
      @devices.each do |device|
        begin
          device.write ' '
          device.flush
        rescue
          failed_devices << device
        end
      end
    end

    nil
  end

  def close
    @devices.each &:close
    @devices.clear
  end

  class TrackSensor::NotInitialized < RuntimeError; end

private

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
      initialize_device new_device_path
    end
  end

  def initialize_device(device_path)
    return unless File.writable? device_path
    `stty 1200 cs7 cstopb < #{device_path}`
    @devices << File.open(device_path, 'r+')
  end

  def parse_times(times_string)
    times = []
    times_string.chomp.split(/ +/).each_slice(2) do |values|
      track, time = values
      if !time
        times << {:time => track.to_f, :track => 1} # Single track mode
      else
        times << {:time => time.to_f, :track => track.to_i} # Multi track mode
      end
    end

    times
  end
end
