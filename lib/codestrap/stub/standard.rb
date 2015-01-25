require 'erb'

module Codestrap
  module Stub
    # Standard file (erb) render
    class Standard < Abstract

      def initialize(*args)
      end

      def pre
        @erb          = ERB.new(File.read(self.src))
        @erb.filename = self.src
      end

      def execute
        ns = Codestrap::Namespace.new(@objects.objects)
        file.write @erb.result(ns.get_binding)
        file.close
      end
    end
  end
end
