require 'codestrap/object/abstract'
require 'ostruct'

module Codestrap
  module Object
    module Standard
      # Project metadata derived object
      class Project < Codestrap::Object::Abstract
        class << self
          # Object(s) weight
          # @return [Integer]
          def weight
            50
          end

          def objects
            objects = {}
            if Project.cli
              project = OpenStruct.new()
              mod = Project.cli.command
              mod =~ /^(?:stub|strap)(\S+)$/
              project.module  = $1
              project.name = File.basename(Project.cli.argv[0])

              objects['project'] = project
            end
            objects
          end
        end
      end
    end
  end
end