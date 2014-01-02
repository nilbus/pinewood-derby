require 'monkeypatches/io'

describe 'IO#readline_nonblock' do
  before :each do
    @in, @out = IO.pipe
  end

  after :each do
    @in.close
    @out.close
  end

  it 'reads lines sequentially when several are queued' do
    @out.puts "one\ntwo\n"
    expect(@in.readline_nonblock).to eq "one\n"
    expect(@in.readline_nonblock).to eq "two\n"
  end

  it 'reads a line when only one is queued' do
    @out.puts "one\n"
    expect(@in.readline_nonblock).to eq "one\n"
  end

  it 'it reads a partial line when the buffer does not end @in a newline' do
    @out.write "half"
    expect(@in.readline_nonblock).to eq "half"
    expect{@in.readline_nonblock}.to raise_exception(IO::WaitReadable)
  end

  it 'raises IO::WaitReadable after reading all remaining data' do
    @out.puts "one\n"
    expect(@in.readline_nonblock).to eq "one\n"
    expect{@in.readline_nonblock}.to raise_exception(IO::WaitReadable)
  end

  it 'raises IO::WaitReadable with an empty buffer' do
    expect{@in.readline_nonblock}.to raise_exception(IO::WaitReadable)
  end
end
