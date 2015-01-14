module Codestrap
  module Mixin
    module Exceptions
      module Factory
        class FactoryException < Exception; end
        class FactoryAbstractMethod < Exception; end
        class FactoryNotImplemented < Exception; end
        class FactoryArgumentError < ArgumentError; end
        class FactoryMethodEnforcement < ArgumentError; end
      end
      module Template
        class RendererAbstractOnly < Exception; end
        class RendererRequiredMethod < Exception; end
        class RendererCannotOverwrite < Exception; end
        class RendererTypeError < Exception; end
        class RendererMissingRoot < Exception; end
      end
    end
  end
end