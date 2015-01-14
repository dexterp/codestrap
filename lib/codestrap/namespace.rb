require 'ostruct'

module Codestrap
  class Namespace
    def initialize(hash)
      hash.each do |key, value|
        add_object key, value
      end
    end

    def get_binding
      binding
    end

    def add_object key, value
      singleton_class.send(:define_method, key.to_s) { value }
    end
  end
end