# frozen_string_literal: true

module Lite
  module Containers
    class AvlTree
      class Node
        attr_reader :key
        attr_accessor :value, :height, :left, :right

        def self.instance(key, value)
          new key, value
        end

        private_class_method :new

        def initialize(key, value)
          @key = key
          @value = value
          @height = 1
          @left = nil
          @right = nil
        end

        def out
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        def inspect
          lr = "#{left.nil? ? 0 : :L}|#{right.nil? ? 0 : :R}"
          "#<#{self.class.name} @key: #{key}, @value: #{value}, @height: #{height} #{lr}"
        end
      end
    end
  end
end
