require 'logger'

module Codestrap
  # Logging with pre set error messages
  #
  # The Log class has been designed to keep track of all possible messages the program will generate
  class Log < Logger
    @@msgs = {
        CODESTRAPMISSING: Proc.new { |*args| sprintf %q[Could not find codestrap "%s".], *args },
        BPMISSING:        Proc.new { |*args| sprintf %q[Could not find boilerplate "%s".], *args },
        INVALID_CMD:      Proc.new { |*args| sprintf %q[Invalid command "%s".], *args },
        GENERATE_NOTLINK: Proc.new { |*args| sprintf %q[File "%s" is not a symlink.], *args }
    }

    def initialize(logdev = STDERR, shift_age = 0, shift_size = 1048576)
      self.level = Logger::WARN
      super(logdev, shift_age, shift_size)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def error(msg, *args)
      super @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def warn(msg, *args)
      super @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def info(msg, *args)
      super @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def debug(msg, *args)
      super @@msgs[msg].call(*args)
    end
  end
end
