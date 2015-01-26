require 'cucumber'
require 'find'
require 'fileutils'
require 'json'
require 'rack/test'
require 'rspec/expectations'
require 'codestrap'
require 'codestrap/version'
require 'codestrap/server/rest'
require 'stringio'
require 'tempfile'
require 'tmpdir'
require 'webmock/cucumber'
require 'yaml'

ROOT         = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
FIXTURE_ROOT = File.join(ROOT, 'features', 'fixtures')
BINDIR       = File.join(ROOT, 'bin')
TMPDIR       = File.join(ROOT, 'tmp')
FIXTURES     = %W[stub strap server client logging]

$LOAD_PATH.unshift File.join(ROOT, 'lib')

Codestrap::Server::Rest.set :environment => :development

class MyWorld
  include Rack::Test::Methods

  def app
    @app = Rack::Builder.new do
      run Codestrap::Server::Rest
    end
  end
end

World do
  MyWorld.new
end

def diff_tree?(left, right)
  left_tree = []
  Dir.chdir(left) do
    left_tree = Dir.glob('**').sort { |a,b| a.length <=> b.length }
  end
  right_tree = []
  Dir.chdir(right) do
    right_tree = Dir.glob('**').sort { |a,b| a.length <=> b.length }
  end

  if left_tree != right_tree
    return 1
  end

  left_tree.each do |file|
    left_file  = File.join(left, file)
    right_file = File.join(right, file)
    left_stat  = File::Stat.new(left_file)
    right_stat = File::Stat.new(right_file)
    if left_stat.ftype != right_stat.ftype
      return 1
    end
    next if left_stat.directory?
    unless FileUtils.compare_file(left_file, right_file)
      return 1
    end
  end

  0
end

# Capture cli methods
module Capture
  class Cli
    # Get & Set
    attr_reader :object_exit
    attr_reader :stdout
    attr_reader :stderr

    def object_exit= object_exit
      raise TypeError, %q[expecting type SystemExit] unless object_exit.is_a?(SystemExit)
      @object_exit = object_exit
    end

    def initialize(divertstdout=true, divertstderr=false)
      @stdout       ||= String.new
      @stderr       ||= String.new
      @divertstdout = divertstdout
      @divertsterr  = divertstderr
    end

    def inline
      begin
        if @divertstdout
          @origstdout = $stdout
          $stdout     = StringIO.new(@stdout)
        end
        if @divertstderr
          @origstderr = $stderr
          $stderr     = StringIO.new(@stderr)
        end
        yield
      rescue SystemExit => e
        self.object_exit = e
      ensure
        $stdout = @origstdout if @divertstdout
        $stderr = @origstderr if @divertsterr
      end
      self
    end

    def self.inline
      Capture::Cli.new().inline do
        yield
      end
    end
  end
end

module Tools
  class Cli
    def initialize
      @env_original = ENV['PATH']
    end

    def path_unshift path
      unless ENV['PATH'].split(':').include?(path.to_s)
        ENV['PATH'] = "#{path}:#{ENV['PATH']}"
      end
    end

    def path_reset
      ENV['PATH'] = @env_original
    end
  end
  class Test
    def self.list_tree(project)
      Find.find(project).map { |dir| dir.gsub(/#{Regexp.escape(project)}/, '') }
    end

    def self.contents(test_hash)
      test_hash.each_pair do |file, tests|
        content = File.read(File.join(file))
        tests.each_pair do |str, bool|
          yield content, str, bool
        end
      end
    end
  end
end

module JSON
  def self.is_json?(foo)
    begin
      return false unless foo.is_a?(String)
      JSON.parse(foo).all?
    rescue JSON::ParserError
      false
    end
  end
end

Before do
  # Web mock
  WebMock.allow_net_connect!
  stub_request(:any, /127.0.0.1/).to_rack(Codestrap::Server::Rest)

  # Copy fixures to tmp/
  FIXTURES.each do |dir|
    fixture = File.join(FIXTURE_ROOT, dir)
    newpath = File.join(TMPDIR, dir)
    cmd     = File.join(BINDIR, 'strap')
    next unless File.exist? fixture
    FileUtils.cp_r fixture, TMPDIR
    Dir.glob("#{newpath}/**/bin").each do |path|
      stub  = File.join(path, 'stub')
      strap = File.join(path, 'strap')
      FileUtils.cp cmd, strap unless File.exist? strap
      FileUtils.ln_s strap, stub unless File.exist? stub
    end
  end

  # Set path
  @testtools = Tools::Cli.new()

  # Project temporary directory
  @tmpdir    = TMPDIR

  # Current directory
  @curdir    = Dir.getwd

  # Original environment variable
  Dir.chdir @tmpdir
end

After do
  Dir.chdir @curdir
end
