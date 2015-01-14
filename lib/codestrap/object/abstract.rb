require 'codestrap/object/abstract'

module Codestrap
  module Object
    # @abstract
    # Objects used in templates
    #
    # Contains class methods used by object factory
    class Abstract
      class << self
        # List of directories
        # @!attribute [rw] files
        # @return [Array]
        attr_accessor :dirs

        # CLI object
        # @!attribute [rw] cli
        # @return [Codestrap::CLI]
        attr_accessor :cli

        # Configuration object
        # @!attribute [rw] config
        # @return [Codestrap::Config]
        attr_accessor :config

        # REST clients
        # @!attribute [rw] clients
        # @return [Array<Codestrap::Clients>]
        attr_accessor :clients
      end
    end
  end
end