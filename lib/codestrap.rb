require 'etc'
require 'logger'
require 'codestrap/cli'
require 'codestrap/client'
require 'codestrap/config'
require 'codestrap/log'
require 'codestrap/namespace'
require 'codestrap/object/factory'
require 'codestrap/object/standard/datetime'
require 'codestrap/strap/factory'
require 'codestrap/strap/abstract'
require 'codestrap/strap/standard'
require 'codestrap/stub/factory'
require 'codestrap/stub/abstract'
require 'codestrap/stub/standard'
require 'codestrap/version'

module Codestrap
  class Core
    # Codestrap template path
    #
    # @return [String]
    attr_reader :template

    # Boilerplate template path
    #
    # @return [String]
    attr_reader :project

    # Command line object
    #
    # @return [Codestrap::Cli]
    attr_accessor :cli

    # List of client objects
    #
    # @return [Array<Codestrap::Client>]
    attr_accessor :clients

    # Configuration object created from Codestrapfile
    #
    # @return [Codestrap::Config]
    attr_accessor :config

    # Set stub template
    # @param [String] template
    #   Codestrap name
    # @return [String|nil]
    #   Codestrap name or nil
    def template=(template)
      # Local templates
      @config.local.content.each do |path|
        next unless File.directory? path
        ['.erb'].each do |prefix|
          templatepath = File.join(path, "#{template}#{prefix}")
          next unless File.exist? templatepath
          @template = templatepath
          return @template
        end
      end

      # Remote templates
      @clients.each do |client|
        templatepath = client.getstub(template)
        next unless templatepath and File.exist? templatepath
        @template = templatepath
        return @template
      end

      logger.error :STUBMISSING, template
      exit 1
    end

    # Set strap project
    # @param [String] project
    #   Boilerplate name
    # @return [String|nil]
    #   Boilerplate name or nil
    def project=(project)
      # Local templates
      @config.local.content.each do |path|
        next unless File.directory? path
        projectpath = File.join(path, project)
        next unless File.directory?(projectpath)
        @project = projectpath
        return @project
      end

      # Remote templates
      @clients.each do |client|
        projectpath = client.getstrap(project)
        next unless projectpath and File.exist? projectpath
        @project = projectpath
        return @project
      end

      logger.error :STRAPMISSING, project
      exit 1
    end

    # Logging object
    # @return [Codestrap::Log]
    def logger
      self.class.logger
    end

    # Logging object
    # @return [Codestrap::Log]
    def self.logger
      @@logger ||= begin
        logger  = Codestrap::Log.new
        @@logger = logger
      end
    end

    def initialize(argv=nil)
      # CLI options
      if argv
        self.cli = Codestrap::Cli.new argv
        self.cli.options
      end

      # Config
      @config = Codestrap::Config.new

      case @config.local.urls
        when Array
          @config.local.urls.each do |url|
            @clients ||= []
            @clients << Codestrap::Client.new(url)
          end
        when String
          @clients ||= []
          @clients << Codestrap::Client.new(@config.local.urls)
        when NilClass
        else
          raise Exception, 'Unknown data structure'
      end
      self
    end

    def execute!
      # Run type
      case
        when cli.command =~ /stub(.+)$/
          self.template = $1
          stub
        when cli.command =~ /strap(.+)$/
          self.project = $1
          strap
        when self.cli.options.generate
          strap_links
        else
          logger.error :INVALID_CMD, cli.command
          exit 1
      end

      exit 0
    end

    def stub(dst=nil, src=nil)
      # Create objects
      obj         = Codestrap::Object::Factory.new
      obj.dirs    = @config.local.objects
      obj.clients = @clients
      obj.cli     = @cli
      obj.config  = @config

      argv             = self.cli.argv

      # Render setup
      renderer         = Codestrap::Stub::Factory.new('Standard').construct(argv)
      renderer.objects = obj
      renderer.src     = src || self.template
      renderer.dst     = dst || self.cli.argv[0]
      renderer.pre
      renderer.execute
      renderer.post
      renderer.to_disk
    end

    def strap(dst=nil, src=nil)
      # Create objects
      obj         = Codestrap::Object::Factory.new
      obj.dirs    = @config.local.objects
      obj.clients = @clients
      obj.cli     = @cli
      obj.config  = @config

      argv             = self.cli.argv
      renderer         = Codestrap::Strap::Factory.new('Standard').construct(argv)
      renderer.ignore  = @config.local.ignore
      renderer.objects = obj
      renderer.src     = src || self.project
      renderer.dst     = dst || self.cli.argv[0]
      renderer.pre
      renderer.execute
      renderer.post
      renderer.to_disk
    end

    def strap_links
      # FixMe - Move to Codestrap::Log
      unless cli.command =~ /^strap$/
        logger.error(:LINKTARGET, cli.command, 'strap')
        exit 1
      end

      # stub templates
      newtemplates = list_stubs.map { |f| File.basename(f, '.erb') } - list_cmds.select { |f| f =~ /^stub/ }.map { |f| f =~ /^stub(.+)$/; $1 }

      newtemplates.each do |file|
        link = File.expand_path(File.join(@config.local.links, 'stub' + file))
        if File.symlink?(link) and File.exist?(File.readlink(link))
          next
        elsif File.symlink?(link)
          File.unlink link
        end

        File.symlink cli.abspath, link
      end

      # strap templates
      newprojects = list_straps - list_cmds.select { |f| f =~ /^strap/ }.map { |f| f =~ /^strap(.+)$/; $1 }

      newprojects.each do |project|
        link = File.expand_path File.join(@config.local.links, 'strap' + project)
        if File.symlink?(link) and File.exist?(File.readlink(link))
          next
        elsif File.symlink?(link)
          File.unlink link
        end

        File.symlink cli.abspath, link
      end
    end

    # Generate strap metadata
    #
    # @param [String] name
    #   Optional module name
    # @param [Hash] options
    #   Flags to turn off/on metadata
    #     {
    #       :src   => [true|false]
    #       :ftype => [true|false]
    #       :mode  => [true|false]
    #     }
    # @param [Array] paths
    #   Optional path list for content search
    # @return [Hash]
    #   Strap directory structure metadata
    #     {
    #       'strap_name' => {
    #         :files => [
    #           {
    #             :file  => 'relative/tree/file/path',
    #             :src   => '/absolute/file/source',
    #             :ftype => 'File type as returned by File::Stat.new(file).ftype, EG "file", "directory"'
    #             :mode  => 'File mode as returned by File::Stat.new(file).mode'
    #           }
    #         ]
    #       }
    #     }
    def strap_metadata(name=nil, options=nil, paths=@config.local.content)
      # TODO - rename
      tree    = {}
      options ||= {src: false, ftype: true, mode: true}
      cur_dir = Dir.pwd
      paths.each do |path|
        next unless File.directory? path
        Dir.chdir(path) do
          Dir.entries('.').each do |mod|
            next if mod =~ /^\.{1,2}$/
            next unless File.directory? mod
            next if name and not name.eql? mod
            next if tree.has_key? mod
            tree[mod] = {files: []}
            Dir.chdir(mod) do
              Dir.glob('**/**').each do |file|
                stat       = File.stat file
                obj        = {}
                obj[:file] = file
                if options[:src]
                  case path
                    when %r{^/}
                      obj[:src] = File.expand_path(File.join(path, mod, file))
                    else
                      obj[:src] = File.expand_path(File.join(cur_dir, path, mod, file))
                  end
                end
                obj[:ftype] = stat.ftype if options[:ftype]
                obj[:mode]  = sprintf('%o', stat.mode) if options[:mode]
                tree[mod][:files] << obj
              end
            end
          end
        end
      end
      tree
    end

    def stub_metadata(name=nil, options=nil, paths=@config.local.content)
      # TODO - rename
      codestraps   = {}
      options ||= {src: false, ftype: true, mode: true}
      paths.each do |path|
        full_path = File.expand_path path
        next unless File.directory? full_path
        Dir.chdir(full_path) do
          Dir.entries('.').each do |file|
            next if file =~ /^\.{1,2}$/
            next unless File.file? file
            next if name and not name.eql? File.basename(file, '.erb')
            mod                = File.basename(file, '.erb')
            stat               = File.stat file
            codestraps[mod]         = {}
            codestraps[mod][:src]   = File.expand_path(File.join(full_path, file)) if options[:src]
            codestraps[mod][:ftype] = stat.ftype if options[:ftype]
            codestraps[mod][:mode]  = sprintf('%o', stat.mode) if options[:mode]
          end
        end
      end
      codestraps
    end

    # Available codestraps from local and server
    #
    # @return [Array]
    def list_stubs
      codestraps = []
      if @clients
        @clients.each do |client|
          codestraps ||= []
          codestraps += client.stublist || []
          codestraps.flatten!
        end
      end
      @config.local.content.each do |dir|
        next unless File.directory? dir
        Dir.chdir(dir) do
          codestraps += Dir.glob('*.erb').select { |f| File.file? f }
        end
      end
      codestraps.uniq
    end

    # Available projects from local and server
    #
    # @return [Array]
    def list_straps
      straps = []
      if @clients
        @clients.each do |client|
          straps ||= []
          straps += client.straplist || []
          straps.flatten!
        end
      end
      @config.local.content.each do |dir|
        next unless File.directory? dir
        if File.directory? dir
          Dir.chdir(dir) do
            straps += Dir.glob('*').select { |f| File.directory? f }
          end
        end
      end
      straps.uniq
    end

    # List all stub.. and strap.. commands
    #
    # @return [Array]
    def list_cmds
      links = []
      dir   = @config.local.links
      if File.directory? dir
        Dir.chdir(dir) do
          Dir.glob('*').each do |f|
            next unless File.symlink? f
            next unless f =~ /^(?:stub|strap)[A-Za-z0-9._-]+$/
            links.push f
          end
        end
      end
      links
    end

    alias_method :ls_codestrap, :list_stubs
    alias_method :ls_strap, :list_straps
    alias_method :ls_cmd, :list_cmds
  end
end
