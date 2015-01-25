module Codestrap
  # Logging with pre set error messages
  #
  # The Log class has been designed to keep track of all possible messages the program will generate
  class Log
    @@msgs = {
        STRAPMISSING:     Proc.new { |*args| sprintf %q[Could not find project "%s".], *args },
        STUBMISSING:      Proc.new { |*args| sprintf %q[Could not find template "%s".], *args },
        NOPATH:           Proc.new { |*args| sprintf %q[No path to "%s".], *args },
        LINKTARGET:       Proc.new { |*args| sprintf %q[Invalid link target "%s". The link target must be the "%s" command], *args },
        INVALIDCMD:       Proc.new { |*args| sprintf %q[Invalid command "%s".], *args },
        FILEEXISTS:       Proc.new { |*args| sprintf %q[File "%s" exists. Can not overwrite.], *args },
        GENERATE_NOTLINK: Proc.new { |*args| sprintf %q[File "%s" is not a symlink.], *args },
    }

    # Log pre set fatal message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def fatal(msg, *args)
      puts @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def error(msg, *args)
      puts @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def warn(msg, *args)
      puts @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def info(msg, *args)
      puts @@msgs[msg].call(*args)
    end

    # Log pre set error message
    #
    # @param [Symbol] msg
    # @param [Array] args
    def debug(msg, *args)
      puts @@msgs[msg].call(*args)
    end
  end
end
