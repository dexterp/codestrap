require 'codestrap/patch'
require 'ostruct'
require 'yaml'
require 'json'
require 'codestrap/object/standard/datetime'
require 'codestrap/object/standard/files'
require 'codestrap/object/standard/project'
require 'codestrap/object/standard/rest'
module Codestrap
  module Object
    class Factory
      def initialize(*args)
        @namespace = args.shift.capitalize if args.length > 0
        @namespace ||= 'Standard'
      end

      # Directories where to find static object files
      # @!attribute [rw] files
      # @return [Codestrap::Config]
      attr_accessor :dirs

      # CLI object
      # @!attribute [rw] cli
      # @return [Codestrap::CLI]
      attr_accessor :cli

      # Configuration object
      # @!attribute [rw] config
      # @return [Codestrap::Config]
      attr_accessor :config

      # Array of client objects
      # @!attribute [rw] clients
      # @return [Array<Codestrap::Client>]
      attr_accessor :clients

      # Generate a hash of key, value pair
      # If value is of type Hash it is converted into an [OpenStruct] object
      #
      # @return [Hash]
      def objects
        objects = {}
        scan.each_pair do |key, value|
          case value
            when Hash
              objects[key] = OpenStruct.new(value)
            else
              objects[key] = value
          end
        end
        objects
      end

      # Scan for objects
      #
      # @return [Hash]
      def scan
        objects = {}
        scan_class = "Codestrap::Object::#{@namespace.to_s}".split('::').inject(Object) { |o, c| o.const_get c }
        klasses = scan_class.constants.map do |constant|
          "Codestrap::Object::Standard::#{constant.to_s}".split('::').inject(Object) { |o, c| o.const_get c }
        end
        Array(klasses).sort { |a, b| a.weight <=> b.weight }.each do |klass|
          klass.dirs    = @dirs
          klass.cli     = @cli
          klass.config  = @config
          klass.clients = @clients
          klass.objects.each_pair do |key, value|
            objects[key.downcase] = value
          end
        end
        objects
      end

      def to_hash
        objects = {}
        scan.each_pair do |key, value|
          if value.is_a?(Hash)
            objects[key] = value
          end
        end
        objects
      end
    end
  end
end
