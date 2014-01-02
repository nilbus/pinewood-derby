module TrackSensor
  class MicroWizardFastTrack  < TrackSensor::Base
    TIMES_REGEX = /^([A-H]=\d\.\d+[!"\#$%&] *)+$/

    # @return [Array<Hash>, nil] Race times, if any, in the format:
    #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
    # @raise [IOError] if a device is not plugged in
    def race_results
      communicate do |device|
        begin
          first_char = device.read_nonblock(1)
          line = first_char + device.readline
        end while (line.try(:strip) !~ TIMES_REGEX)
        return parse_times line
      end

      nil
    end

    # @raise [IOError] if a device is not plugged in
    def new_race
      communicate do |device|
        device.write_nonblock 'RA'
        device.flush
      end

      nil
    end

    def serial_params
      {
        baud: 9600,
        data_bits: 8,
        stop_bits: 1,
      }
    end

  private

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
