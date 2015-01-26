require 'singleton'
require 'ostruct'
require 'erb'
require 'codestrap/mixin'
require 'tempfile'

module Codestrap
  module Stub
    # @abstract
    #
    # Template renderer class
    #
    # Methods (aliased to #abstract) that require overriding
    #
    #   #pre
    #
    # Pre execution
    #
    #   #execute
    #
    # Render execution
    #
    # Methods that may be overridden
    #
    #   #post
    #
    class Abstract
      include Codestrap::Mixin::Exceptions::Template

      # Objects utilized in templates
      # @!attribute [rw] objects
      # @return [Array<Codestrap::Object::Factory>]
      attr_accessor :objects

      # List methods aliased Codestrap::Template::Abstract#abstract
      # @return [Array]
      def self.abstract_methods
        instance_methods.group_by { |m| instance_method(m) }.map(&:last).keep_if { |sym| sym.length > 1 }.map { |methods|
          if methods.include?('abstract'.to_sym)
            return methods.map { |method| method.to_s }.select { |method| method != 'abstract' }
          end
        }
        []
      end

      # Set file object
      # @!attribute [w] file
      # @return [File]
      attr_writer :file

      # Path to template
      # @!attribute [r] src
      # @return [String]
      attr_reader :src

      # Path to destination project
      # @!attribute [r] dst
      # @return [String]
      attr_reader :dst

      # Allow overwriting of files
      # @!attribute [rw] overwrite
      # @return [true|false]
      attr_accessor :overwrite

      # Check overwrite attribute
      # @return [true|false]
      def overwrite?
        !!@overwite
      end

      # Set source template
      #
      # @param [String] src
      #   Path to source file
      def src=(src)
        raise Exception, %q[File doesn't exist] unless File.exist?(src)
        @src = src
      end

      # Set destination file
      #
      # @param [String] dst
      #   Path to destination file
      def dst=(dst)
        if !overwrite? and File.exist? dst
          Codestrap::Core.logger.error(:FILEEXISTS, dst)
          exit 255
        end
        unless File.exist?(File.dirname(dst))
          Codestrap::Core.logger.error(:NOPATH, dst)
          exit 255
        end
        @dst = dst
      end

      # Abstract class. Raise error on instantiation
      def initialize()
        raise RendererAbstractOnly, 'Abstract Class Requires implementation'
      end

      # @abstract
      # Method(s) aliased to this method are considered abstract
      # @raise [RendererRequiredMethod]
      #   Raise an error if a method remains aliased to this method
      def abstract
        raise RendererRequiredMethod, "Method #{__method__.to_s} not implemented"
      end

      # Pre execution method
      alias :pre :abstract

      # Execution method
      alias :execute :abstract

      # Post execution method
      def post
      end

      # Creates and returns Tempfile to working file
      #
      # @return [Tempfile]
      #   Path to temporary file
      def file
        @file ||= Tempfile.new('codestrap')
      end

      # Moves #file contents to #dst
      #
      # @return [Integer]
      #   Returns 0 on success
      def to_disk
        @file.close
        FileUtils.mv self.file.path, self.dst
      end
    end
  end
end