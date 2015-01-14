require 'codestrap/mixin'

module Codestrap
  module Boilerplate
    # Factory for instantiating classes from the Codestrap::Boilerplate namespace
    class Factory
      include Codestrap::Mixin::Exceptions::Factory

      attr_reader :klass

      # Factory constructor for Codestrap::Template::* Classes
      #
      # @param [Class, Symbol, String] nklass
      # @return [Codestrap::Template::Factory]
      def initialize(nklass)
        self.klass = nklass
        enforce_methods
        ensure_required
      end

      # Constructor for Codestrap::Boilerplate::* Classes
      #
      # @param [Array] args
      #   Arguments to pass to constructor of child object
      # @return [Object]
      #   Return the object as specified Factory#klass.new(args)
      def construct(*args)
        self.klass.new(args)
      end

      # Dynamic Class creation.
      # Looks for Classes in Codestrap::Boilerplate::NKLASS
      #
      # @param [String|Symbol] nklass
      #   Look for Codestrap::Template::nklass
      # @raise [FactoryArgumentError]
      #   Raised if nklass is not type String or type Symbol
      # @return [Codestrap::Template::KLASS]
      #   Return class Codestrap::Template::KLASS
      def to_class nklass
        case
          when nklass.is_a?(Symbol)
            klass = nklass.to_s
          when nklass.is_a?(String)
            klass = nklass
          else
            raise ArgumentError, %Q(Could not find Class Codestrap::Boilerplate::#{nklass.to_s})
        end
        @klass = ['Codestrap', 'Boilerplate', klass].reduce(Module, :const_get)
        @klass
      end

      alias :klass= :to_class

      # Ensure self.klass has the following methods
      #
      #   klass.pre
      #   klass.execute
      #
      # Inherited from Codestrap::Template::Factory
      #   klass.file
      #   klass.finalize
      #
      # @raise [FactoryMethodEnforcement]
      #   Raised if a enforced method doesn't exist in the child
      # @return [TrueClass, FalseClass]
      def enforce_methods
        [:pre, :execute, :overwrite, :overwrite=, :working_dir, :to_disk].each do |method|
          next if @klass.method_defined? method
          raise FactoryException, "Error missing method #{@klass.to_s}##{method}"
        end
      end

      # Ensures any methods aliased to abstract_method are overridden
      # @raise [FactoryAbstractMethod]
      #   Raised if a abstract method (A method aliased to abstract_method), is not created in the child
      def ensure_required
        if @klass.abstract_methods.length > 0
          methods = @klass.abstract_methods.map{ |method| "#{@klass.to_s}##{method}" }
          raise FactoryException, "Abstract Method(s) #{methods.join(', ')} not overridden"
        end
      end
    end
  end
end