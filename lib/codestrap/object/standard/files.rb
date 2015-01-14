require 'codestrap/object/abstract'

module Codestrap
  module Object
    module Standard
      # Static file derived objects
      #
      # Create objects from .json, .yaml and executable files
      class Files < Codestrap::Object::Abstract
        class << self
          # Object(s) weight
          # @return [Integer]
          def weight
            100
          end

          def objects
            objects = {}

            glob_array = Array(Files.dirs).map { |file| File.join(File.expand_path(file), '*') }
            Codestrap::Patch::Dir.glob_files(glob_array).each do |file|
              stat = File::Stat.new file
              name = File.basename(file, File.extname(file)).downcase
              case
                when /\.json$/.match(file)
                  objects[name] = JSON.load(File.read(file))
                when /\.yaml$/.match(file)
                  objects[name] = YAML.load(File.read(file))
                when stat.executable?
                  objects[name] = JSON.parse(`#{file}`)
              end
            end

            objects
          end
        end
      end
    end
  end
end