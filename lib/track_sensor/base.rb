class TrackSensor::Base
  def initialize(options = {})
    @device_glob = options[:device_glob] || '/dev*/tty{USB,.usbserial}*'
    @devices = []
    @data = {}
    initialize_new_devices
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

  def communicate
    scan_for_device_changes do |failed_devices|
      @devices.each do |device|
        yield device, failed_devices
      end
    end
  end

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
      device = initialize_device(new_device_path)
      @devices << device if device
    end
  end
end
