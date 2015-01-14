require 'codestrap/object/abstract'

module Codestrap
  module Object
    module Standard
      # REST derived objects
      #
      # Create objects from codestraps builtin remote REST server
      class Rest < Codestrap::Object::Abstract
        class << self
          # Object(s) weight
          # @return [Integer]
          def weight
            50
          end

          def objects
            objects = {}
            if clients
              Array(clients).each do |client|
                objects = client.getobjects
              end
            end
            objects
          end
        end
      end
    end
  end
end
