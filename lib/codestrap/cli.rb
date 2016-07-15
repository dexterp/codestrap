require 'ostruct'
require 'optparse'
module Codestrap
  class Cli
    class CodestrapPathError < Exception; end
    # Calling command
    # @!attribute [rw] command
    # @return [String]
    attr_accessor :command

    # Same as ARGV
    # @!attribute [rw] argv
    # @return [String]
    attr_accessor :argv

    # Set Environment variables.
    attr_writer :env

    # Environment variables. Defaults to system environment variables
    #
    # @return [Hash]
    def env
      @env ||= ENV.to_hash
    end

    # Absolute path of calling command
    #
    # @param [String] path
    #   Path to command
    # @return [String]
    #   Absolute path to command
    def abspath path=nil
      return @abspath if @abspath and not path
      if path =~ /\//
        p        = File.expand_path(path)
        @abspath = p if File.exist? p
      else
        env['PATH'].split(File::PATH_SEPARATOR).each do |d|
          p = File.join(d, path)
          next unless d.length > 0
          next unless File.exist? p
          @abspath = File.expand_path(p)
          break
        end
      end
      if @abspath
        @abspath
      else
        raise CodestrapPathError, "Could not find #{path}"
      end
    end

    def initialize argv
      self.abspath(argv.shift)
      @command = File.basename self.abspath
      @argv    = argv
    end

    def options
      @options ||= (
      options          = OpenStruct.new
      options.generate = false
      OptionParser.new do |opts|
        opts.banner = "Usage: #{self.command} [-?|-h|--help]"
        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--version', 'Show version') do
          puts Codestrap::VERSION
          exit 0
        end

        opts.on('-?', '-h', '--help', 'Show this message') do
          puts opts
          exit 0
        end

        opts.on('-g', '--generate', 'Generate links') do
          options.generate = true
        end
      end.parse!(self.argv)
      options
      )
    end
  end
end