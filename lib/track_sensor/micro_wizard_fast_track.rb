module TrackSensor
  class MicroWizardFastTrack  < TrackSensor::Base
    def times_regex
      /^@?([A-H]=\d\.\d+[!"\#$%& ]? ?)+\r?$/
    end

    def new_race
      nil
    end

    def serial_params
      {
        baud: 9600,
        data_bits: 8,
        stop_bits: 1,
      }
    end

    def self.random_result_example(lanes = 4)
      possible_lanes = 6
      random_time = ->{ "%.3f" % (rand * 10) }
      times = []
      lanes.times { times << random_time[] }
      sorted_times = times.sort
      (possible_lanes - lanes).times { times << 0.0 }
      ranks = times.each_with_object([]) do |time, ranks|
        ranks << sorted_times.index(time)
      end
      rank_symbols = {0 => '!', 1 => '"', 2 => '#', 3 => '$', 4 => '%', 5 => '&', nil => ' '}
      ranks = ranks.map { |numeric_rank| rank_symbols[numeric_rank] }

      %Q(@A=#{times[0]}#{rank_symbols[0]} B=#{times[1]}#{rank_symbols[1]} C=#{times[2]}#{rank_symbols[2]} D=#{times[3]}#{rank_symbols[3]} E=#{times[4]}#{rank_symbols[4]} F=#{times[5]}#{rank_symbols[5]} \r\n)
    end

  private

    def parse_times(times_string)
      times = times_string.chomp.split(/ +/).map do |value|
        time = value[/\d\.\d+/].to_f
        track_letter = value[/^@?([A-H])=/, 1]
        {:time => time, :track => convert_track_letter_to_number(track_letter)}
      end

      times[0, DerbyConfig.lane_count]
    end

    def convert_track_letter_to_number(letter)
      letter.upcase.ord - ?A.first.ord + 1
    end
  end
end
