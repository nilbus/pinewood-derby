require 'spec_helper'

describe TrackSensor::NewboldDt8000 do
  subject(:track_sensor) { described_class.new device_glob: "{#{device_path},#{secondary_path},/tmp/nonexistent,/etc/profile}" } # Include some bad files in the glob; it should read from any/all files
  let(:device_path) { '/tmp/device' }
  let(:device_data) { '' }
  let(:secondary_path) { '/tmp/secondary' }
  before :each do
    File.write device_path, device_data || ''
  end
  after :each do
    FileUtils.rm_f device_path
    FileUtils.rm_f secondary_path
  end

  describe '#race_results' do
    context 'with results queued' do
      let(:device_data) { "\000DT.000  NewBold Products\n1 4.9841 2 4.7612 3 9.4843 4 8.0934\n" }

      it 'returns the results in track order' do
        expect(track_sensor.race_results).to eq [
          {time: 4.9841, track: 1},
          {time: 4.7612, track: 2},
          {time: 9.4843, track: 3},
          {time: 8.0934, track: 4},
        ]
        expect(track_sensor.race_results).to be_nil
      end
    end

    context 'when there are no results' do
      it 'returns nil' do
        expect(track_sensor.race_results).to be_nil
      end
    end
  end

  describe '#new_race' do
    it 'writes a space character to the device' do
      track_sensor.new_race
      expect(File.read(device_path)).to eq ' '
    end
  end

  describe '#close' do
    it 'closes all open devices' do
      # There are no external effects, so ...
      expect{track_sensor.close}.not_to raise_exception
    end
  end

  describe 'hot changing devices' do
    let(:device_data) { "1 5.9841 2 4.7612 3 9.4843 4 8.0934\n" }

    it 'attempts to read from any/all of the files specified in the :device_glob option' do
      expect(track_sensor.race_results.size).to eq 4
      expect(track_sensor.race_results).to be_nil
      File.write device_path, ''
      File.write secondary_path, "1 6.9841 2 4.7612 3 9.4843 4 8.0934\n"
      expect(track_sensor.race_results.first[:time]).to eq 6.9841
    end
  end

  context 'with no device files' do
    it 'raises an IOError' do
      sensor = described_class.new device_glob: '/tmp/whoopsitsnotthere'
      expect { sensor.race_results }.to raise_exception IOError, 'The sensor is not plugged in'
    end
  end
end
