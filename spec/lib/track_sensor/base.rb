require_relative 'test_pty'

shared_examples 'track sensors' do
  subject(:track_sensor) { described_class.new device_glob: "{#{@device.path},#{@second_device.path},/tmp/nonexistent,/etc/profile}" } # Includes some bad files in the glob; it should read from any/all files

  let(:device_data) { '' }

  before :each do
    @device        = TestPTY.new
    @second_device = TestPTY.new
    @device.pty.write device_data
  end

  after :each do
    @device.close
    @second_device.close
  end

  describe '#race_results' do
    context 'with results queued' do
      let(:device_data) { device_initialization_data + result_data }

      it 'returns the results in track order' do
        expect(track_sensor.race_results).to eq [
          {time: 3.1, track: 1},
          {time: 3.2, track: 2},
          {time: 3.3, track: 3},
          {time: 3.4, track: 4},
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
      expect(@device.pty.read_nonblock(new_race_command.length)).to eq new_race_command
    end
  end

  describe '#close' do
    it 'closes all open devices' do
      # There are no external effects, so ...
      expect{track_sensor.close}.not_to raise_exception
    end
  end

  describe 'hot changing devices' do
    let(:device_data) { result_data }

    it 'attempts to read from any/all of the files specified in the :device_glob option' do
      expect(track_sensor.race_results.size).to eq 4
      expect(track_sensor.race_results).to be_nil
      @second_device.pty.write device_data.sub('3', '2')
      expect(track_sensor.race_results.first[:time]).to eq 2.1
    end
  end

  context 'with no device files' do
    it 'raises an IOError' do
      sensor = described_class.new device_glob: '/tmp/whoopsitsnotthere'
      expect { sensor.race_results }.to raise_exception IOError, 'The sensor is not plugged in'
    end
  end
end
