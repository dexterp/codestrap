require 'codestrap/mixin'
require 'tmpdir'

module Codestrap
  module Strap
    # @abstract
    #
    # Boilerplate renderer class
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
      # @return [Codestrap::Object::Factory]
      attr_accessor :objects

      # List of files to ignore
      # @!attribute [rw] ignore
      # @return [Array]
      attr_accessor :ignore

      # List methods aliased to Codestrap::Template::Abstract#abstract
      # @return [Array]
      def self.abstract_methods
        instance_methods.group_by { |m| instance_method(m) }.map(&:last).keep_if { |sym| sym.length > 1 }.map { |methods|
          if methods.include?('abstract'.to_sym)
            return methods.map { |method| method.to_s }.select { |method| method != 'abstract' }
          end
        }
        []
      end

      # Path to project
      # @!attribute [r] src
      # @return [String]
      attr_reader :src

      # Path to destination file
      # @!attribute [r] dst
      # @return [String]
      attr_reader :dst

      # Allow overwrite of files
      # @!attribute [rw] overwrite
      # @return [true|false]
      attr_accessor :overwrite

      # Check overwrite attribute
      # @return [true|false]
      def overwrite?
        !!@overwrite
      end

      # Set source project
      #
      # @param [String] src
      #   Path to source directory
      def src=(src)
        raise Exception, %q[File doesn't exist] unless File.exist?(src)
        @src = src
      end

      # Set destination project
      #
      # @param [String] dst
      #   Path to destination directory
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
      def initialize
        raise RendererAbstractOnly, 'Abstract Class Requires implementation'
      end

      # @abstract
      # Method(s) aliased to this method are considered abstract
      # @raise [RendererRequiredMethod]
      #   Raise an error if a method remains aliased to this method
      def abstract
        raise RendererRequiredMethod, "Method #{__method__.to_s} not implemented"
      end

      # Pre execution abstract method
      alias :pre :abstract

      # Execution abstract method
      alias :execute :abstract

      # Post execution method
      def post
      end

      # Creates and returns path to working directory
      #
      # @return [Dir]
      def working_dir
        @working_dir ||= Dir.new(Dir.mktmpdir('strap'))
      end

      # Moves #working_dir contents to #dst
      #
      # @return [Integer]
      #   Returns 0 on success
      def to_disk
        FileUtils.mv self.working_dir.path, self.dst
      end

      alias_method :file, :working_dir
    end
  end
end
