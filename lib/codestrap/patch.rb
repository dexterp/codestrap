module Codestrap
  module Patch
    ##
    # Inherited and patched Dir class
    #
    # Used as an alternative to monkey patching
    class Dir < Dir
      ##
      # List existing directories
      # Patched function
      #
      # @param [Array] dirs
      # @return [Array]
      #   Array of directories
      def self.each_dirs_exist(*dirs)
        dirs.select { |dir| File.directory? dir }
      end

      ##
      # List existing directory entries
      # Patched function
      #
      # @param [Array] dirs
      # @return [Array]
      #   Array of directories full path
      def self.glob_directories(*dirs)
        dirs = dirs[0] if dirs[0].is_a? Array
        list = self.glob(dirs).select { |dir| File.directory? dir }
        if block_given?
          list.each do |dir|
            yield dir
          end
        else
          list
        end
      end

      ##
      # List existing file entries
      # Patched function
      #
      # @param [Array] files
      # @return [Array]
      #   Array of directories full path
      def self.glob_files(*files)
        files = files[0] if files[0].is_a? Array
        list  = self.glob(files).select { |file| File.file? file }
        if block_given?
          list.each do |file|
            yield file
          end
        else
          list
        end
      end
    end

    ##
    # Inherited and patched File class
    #
    # Used as an alternative to monkey patching
    class File < File
      ##
      #
      # @return [Symbol|nil]
      #   Template types :erb
      def template
        @template || begin
          self.modeline
          @template
        end
      end

      ##
      # Set and get mode line status
      #
      # @param [Integer] limit
      #   Number of lines to scan from the top
      # @return [true\nil]
      def mode_line(limit = 10)
        @mode_line ||= begin
                         # Check if file read
          curpos   = self.pos
          self.pos = 0
          lines    = self.readlines(limit)
          lines.each do |line|
            line =~ /\b(strap|stub):(erb|)/
            if $1
              @mode_line = line
              @template  = $2.to_sym if $2
              @template  = :erb if $2.length == 0
              self.options
            end
            break
          end
          self.pos = curpos
          @mode_line
        end
      end

      ##
      # Parse mode line options
      def options
        @options ||= begin
          @mode_line.scan(/(\S+)\s*=\s*(\S+)/).each do |arr|
            key           = arr[0]
            value         = arr[1]
            @options[key] = value
          end
          @options
        end
      end

      ##
      # Has mode line
      # @return [true|false]
      def has_mode_line?
        !!self.mode_line
      end
    end
  end
end
