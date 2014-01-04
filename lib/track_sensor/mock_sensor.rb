require 'pty'
require_relative 'newbold_dt8000'
require_relative 'micro_wizard_fast_track'

module TrackSensor
  class MockSensor
    SENSOR_TYPES = ['NewboldDt8000', 'MicroWizardFastTrack']

    def initialize(sensor_type)
      @track_sensor = ::TrackSensor.const_get sensor_type
    end

    def path
      ensure_device_open

      @tty.path
    end

    def send_race_times
      ensure_device_open
      data = @track_sensor.random_result_example
      @pty.write_nonblock data

      data
    end

    def open
      @pty, @tty = PTY.open
      if block_given?
        yield
        close
      end
    end

    def close
      @pty.close
      @tty.close
    end

  private

    def closed?
      @pty.nil? || @pty.closed? || @tty.nil? || @tty.closed?
    end

    def ensure_device_open
      raise IOError, 'MockSensor device not open' if closed?
    end
  end
end
