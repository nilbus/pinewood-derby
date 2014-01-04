require 'spec_helper'

module TrackSensor
  describe MockSensor do
    subject(:mock_sensor) { described_class.new 'NewboldDt8000' }

    describe '::SENSOR_TYPES' do
      it 'returns the TrackSensor class names for the sensor types' do
        sensor_types = described_class::SENSOR_TYPES
        expect(sensor_types).to respond_to :each
        expect(sensor_types.join).to match /\w/
      end
    end

    describe '#initialize' do
      it 'requires a valid sensor type' do
        expect { described_class.new 'NoSuchSensor' }.to raise_error NameError
        expect { described_class.new 'NewboldDt8000' }.not_to raise_error
      end
    end

    describe '#path' do
      context 'with the device file open' do
        it 'returns the device path' do
          mock_sensor.open do
            expect(mock_sensor.path).to match %r(\A/dev/[\w/]+\z)
          end
        end
      end

      context 'without the device file open' do
        it 'raises an error' do
          expect { mock_sensor.path }.to raise_error IOError
        end
      end
    end

    describe '#send_race_times' do
      context 'with the device file open' do
        it 'returns the data sent from the mock sensor' do
          mock_sensor.open do
            expect(mock_sensor.send_race_times).to match /\d\.\d{3}/
          end
        end
      end

      context 'without the device file open' do
        it 'raises an error' do
          expect { mock_sensor.path }.to raise_error IOError
        end
      end
    end
  end
end
