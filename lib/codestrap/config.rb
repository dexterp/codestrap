module Codestrap
  module Server
    class Config
      # Bind IP Address
      # @return [String]
      attr_accessor :bind
      # Port number
      # @return [Integer]
      attr_accessor :port
      # Array of files
      # @return [Array]
      attr_accessor :base
      # Ignore files from boilerplate
      # @return [Array]
      attr_accessor :ignore

      # List of content directories
      # @return [Array]
      def content
        Array(base).map { |dir| File.join(dir, 'content') }
      end

      # List of object directories
      # @return [Array]
      def objects
        Array(base).map { |dir| File.join(dir, 'objects') }
      end
    end
  end
  module Local
    class Config
      # Array of directories
      # @return [Array]
      attr_accessor :base
      # Array of capability URLs
      # @return [Array]
      attr_accessor :urls
      # List of files to ignore when parsing boiler plates
      # @return [Array]
      attr_accessor :ignore
      # Directory to store links to executable
      # @return [String]
      def links
        links = nil
        Array(base).each do |dir|
          path = File.join(dir, 'bin')
          next unless File.exist? path
          links = path
          break
        end
        links
      end

      # List of content directories
      # @return [Array]
      def content
        Array(base).map { |dir| File.join(dir, 'content') }
      end

      # List of object directories
      # @return [Array]
      def objects
        Array(base).map { |dir| File.join(dir, 'objects') }
      end
    end
  end
end

class Codestrapfile
  def self.server
    @@server ||= Codestrap::Server::Config.new
  end

  def self.local
    @@local ||= Codestrap::Local::Config.new
  end

  def server
    @@server ||= Codestrap::Server::Config.new

    if block_given?
      yield @@server
    else
      @@server
    end
  end

  def local
    @@local ||= Codestrap::Local::Config.new

    if block_given?
      yield @@local
    else
      @@local
    end
  end

  def self.config
    obj = Codestrapfile.new()
    yield obj if block_given?
  end
end

module Codestrap
  # Loaded variables from Codestrapfile presented as getters
  class Config
    def initialize
      # Setup defaults
      Codestrapfile.config do |conf|
        conf.local.base  = %W[codestrap .codestrap].map { |d| File.join(ENV['HOME'], d) }
        conf.local.ignore = %W[.git .svn]
        conf.server.bind = '127.0.0.1'
        conf.server.port = '4567'
        conf.server.base = conf.local.base
        conf.server.ignore = conf.local.ignore
      end

      @@codestrapfile_mtime = Time.new(0)
      load_codestrapfile
    end

    def codestrapfile_mtime(codestrapfile)
      if not codestrapfile and ENV['CODESTRAPFILE'] and File.exist? ENV['CODESTRAPFILE']
        codestrapfile = ENV['CODESTRAPFILE']
      end
      if codestrapfile
        return File::Stat.new(codestrapfile).mtime
      else
        return Time.new(0)
      end
    end

    def reload_on_change
      reload   = false
      mtime    = nil
      codestrapfile = nil
      if ENV['CODESTRAPFILE'] and !@@codestrapfile
        reload   = true
        codestrapfile = ENV['CODESTRAPFILE']
        mtime    = codestrapfile_mtime(codestrapfile)
      elsif ENV['CODESTRAPFILE'] and !ENV['CODESTRAPFILE'].eql?(@@codestrapfile)
        reload   = true
        codestrapfile = ENV['CODESTRAPFILE']
        mtime    = codestrapfile_mtime(codestrapfile)
      elsif @@codestrapfile
        mtime = codestrapfile_mtime(@@codestrapfile)
        if mtime > @@codestrapfile_mtime
          reload = true
        end
      end
      if reload
        load codestrapfile
        @@codestrapfile       = codestrapfile
        @@codestrapfile_mtime = mtime
        true
      end
      false
    end

    def load_codestrapfile(codestrapfile=nil)
      codestrapfile_mtime = nil
      unless codestrapfile
        # Load possible codestrapfiles
        [ENV['CODESTRAPFILE'], File.join(ENV['HOME'], 'codestrap', 'Codestrapfile'), File.join(ENV['HOME'], '.codestrap', 'Codestrapfile')].each do |sf|
          next unless sf and File.exist?(sf)
          codestrapfile       = sf
          codestrapfile_mtime = codestrapfile_mtime(sf)
          break
        end
      end

      if codestrapfile
        load codestrapfile
        @@codestrapfile       = codestrapfile
        @@codestrapfile_mtime = codestrapfile_mtime
      end
    end

    def self.local
      @@config ||= Codestrapfile.new
      @@config.local
    end

    def local
      @@config ||= Codestrapfile.new
      @@config.local
    end

    def self.server
      @@config ||= Codestrapfile.new
      @@config.server
    end

    def server
      @@config ||= Codestrapfile.new
      @@config.server
    end
  end
end
