module TrackSensor
  class MicroWizardFastTrack  < TrackSensor::Base
    TIMES_REGEX = /^([A-H]=\d\.\d+[!"\#$%&] *)+$/

    # @return [Array<Hash>, nil] Race times, if any, in the format:
    #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
    # @raise [IOError] if the device is not plugged in
    def race_results
      communicate do |device, failed_devices|
        begin
          line = device.readline while line.try(:strip) !~ TIMES_REGEX
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
          device.write 'RA'
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
      # `stty 9600 cs8 -cstopb < #{device_path}`

      File.open(device_path, 'r+')
    end

    def parse_times(times_string)
      times = times_string.chomp.split(/ +/).map do |value|
        time = value[/\d\.\d+/].to_f
        track_letter = value[/^([A-H])=/, 1]
        {:time => time, :track => convert_track_letter_to_number(track_letter)}
      end

      times[0, DerbyConfig.lane_count]
    end

    def convert_track_letter_to_number(letter)
      letter.upcase.ord - ?A.first.ord + 1
    end
  end
end
