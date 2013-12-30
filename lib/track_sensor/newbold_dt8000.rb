module TrackSensor
  class NewboldDt8000 < TrackSensor::Base
    # @return [Array<Hash>, nil] Race times, if any, in the format:
    #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
    # @raise [IOError] if the device is not plugged in
    def race_results
      communicate do |device, failed_devices|
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

    def new_race
      communicate do |device, failed_devices|
        begin
          device.write ' '
          device.flush
        rescue
          failed_devices << device
        end
      end

      nil
    end

  private

    def initialize_device(device_path)
      return false unless File.writable? device_path
      `stty 1200 cs7 cstopb < #{device_path}`

      File.open(device_path, 'r+')
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
end
