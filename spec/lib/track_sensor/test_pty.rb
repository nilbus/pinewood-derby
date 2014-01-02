require 'pty'

# Read up on pseudo-terminals to learn about pty, tty: http://www.tldp.org/HOWTO/Text-Terminal-HOWTO-7.html#ss7.2
class TestPTY
  def initialize
    @pty, @tty = PTY.open
  end

  attr_reader :pty, :tty

  def path
    @tty.path
  end

  def close
    @pty.close
    @tty.close
  end
end
