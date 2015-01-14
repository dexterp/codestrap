require 'codestrap/object/abstract'
require 'date'

module Codestrap
  module Object
    module Standard
      # Date and Time object directly from Rubys Datetime class
      class Datetime < Codestrap::Object::Abstract
        # Object(s) weight
        # @return [Integer]
        def self.weight
          200
        end

        # Objects
        # @return [Hash]
        #   @option
        def self.objects
          { 'datetime' => DateTime.now }
        end
      end
    end
  end
end