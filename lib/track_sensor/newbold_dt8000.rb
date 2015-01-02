module TrackSensor
  class NewboldDt8000 < TrackSensor::Base
    TIMES_REGEX = /(\d \d\.\d+ ?)+/

    # @return [Array<Hash>, nil] Race times, if any, in the format:
    #   [{track: 2, time: 3.456}, {track: 1, time: 4.105}, ...]
    # @raise [IOError] if a device is not plugged in
    def race_results
      communicate do |device|
        begin
          line = device.readline.strip.chomp
          debug "Ignoring non-time data: #{line}" if line !~ TIMES_REGEX
        end while line !~ TIMES_REGEX
        debug "Read times: #{line}"
        return parse_times line
      end

      nil
    end

    # @raise [IOError] if a device is not plugged in
    def new_race
      communicate do |device|
        device.write ' '
        device.flush
      end

      nil
    end

    def serial_params
      {
        baud: 1200,
        data_bits: 7,
        stop_bits: 2,
      }
    end

    def self.random_result_example(lanes = 4)
      random_time = ->{ "%.4f" % (rand * 10) }
      data = ""
      lanes.times { |i| data << "#{i + 1} #{random_time[]} " }

      data.strip + "\n"
    end

  private

    def parse_times(times_string)
      times = []
      times_string.chomp.split(/ +/).each_slice(2) do |(track, time)|
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
