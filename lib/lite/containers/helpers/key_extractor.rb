# frozen_string_literal: true

require_relative '../error'

module Lite
  module Containers
    module Helpers
      class KeyExtractor
        def self.instance(input)
          return if input.nil?
          return input if input.respond_to? :to_key
          return new input if input.is_a? Proc

          raise Error, "Expected nil, key extractor or a proc, got #{input.inspect}"
        end

        private_class_method :new

        def initialize(block)
          @block = block
        end

        def to_key(element)
          @block.call(element)
        end
      end
    end
  end
end
