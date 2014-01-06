require 'spec_helper'

describe BufferedSerialDevice do
  subject(:buffered_serial_device) { described_class.new device_path, serial_params }
  let(:device_path) { '/dev/ttyUSB0' }
  let(:serial_params) { {baud: 1200, data_bits: 7, stop_bits: 2} }
  let(:serial_port) { double('serial_port', write: 0, close: nil) }

  before :each do
    allow(SerialPort).to receive(:new).and_return(serial_port)
  end

  describe '#initialize' do
    it 'creates a new SerialPort device' do
      buffered_serial_device
      expect(SerialPort).to have_received(:new).with(device_path, serial_params)
    end
  end

  describe '#path' do
    it 'returns the path given to initialize' do
      expect(buffered_serial_device.path).to eq device_path
    end
  end

  describe '#readline' do
    def mock_io(data)
      readable, writable = IO.pipe
      writable.write data

      [readable, writable]
    end

    it 'reads a single full line from the IO buffer' do
      serial_port, _ = mock_io("1 2.345\n2 6.789\n")
      expect(SerialPort).to receive(:new).and_return serial_port
      expect(buffered_serial_device.readline).to eq "1 2.345\n"
      expect(buffered_serial_device.readline).to eq "2 6.789\n"
    end

    it 'raises Errno::EAGAIN when no full lines are in the buffer' do
      # expect(SerialPort).to receive(:new).and_return mock_io('partial'), mock_io(" line\nleftover")
      serial_port, serial_port_writer = mock_io('partial')
      expect(SerialPort).to receive(:new).and_return serial_port
      expect{buffered_serial_device.readline}.to raise_exception Errno::EAGAIN
      serial_port_writer.write(" line\nleftover")
      expect(buffered_serial_device.readline).to eq "partial line\n"
      expect{buffered_serial_device.readline}.to raise_exception Errno::EAGAIN
    end
  end

  describe '#write' do
    it 'delegates to SerialPort#write_nonblock' do
      expect(serial_port).to receive(:write_nonblock).with('data')
      expect(serial_port).to receive(:flush)
      buffered_serial_device.write 'data'
    end
  end

  describe '#close' do
    it 'delegates to SerialPort#close' do
      expect(serial_port).to receive :close
      buffered_serial_device.close
    end
  end

end
