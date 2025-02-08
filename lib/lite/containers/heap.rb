# frozen_string_literal: true

require_relative 'helpers/comparison'
require_relative 'abstract/collection'
require_relative 'abstract/queue'
require_relative 'abstract/implicit_key'

module Lite
  module Containers
    class Heap # rubocop:disable Metrics/ClassLength
      include Abstract::Collection
      include Abstract::ImplicitKey
      include Abstract::Queue

      class Error < StandardError; end

      def self.instance(type, key_extractor: nil)
        comparison = Helpers::Comparison.instance(type, key_extractor: key_extractor)
        with_comparison(comparison)
      end

      def self.with_comparison(comparison)
        new(comparison)
      end

      private_class_method :new

      def initialize(comparison)
        @comparison = comparison
        reset!
        freeze
      end

      def size
        @array.size
      end

      def top
        @array.first
      end

      def front
        top
      end

      def push(value)
        @array.push value
        sift_up(length - 1)
        self
      end

      def replace_top(value)
        sift_down(0, value)
      end

      def pop
        return if length.zero?

        if length == 1
          @array.pop
        else
          value = top
          sift_down(0, @array.pop)
          value
        end
      end

      def pop_front
        pop
      end

      def drain!
        result = []
        result << pop while length.positive?
        result
      end

      def reset!
        if frozen?
          @array.clear
        else
          @array = []
        end
      end

      private

      def parent_index(index)
        ((index - 1) / 2)
      end

      def left_child_value(parent_index)
        index = left_child_index(parent_index)
        @array[index]
      end

      def left_child_index(index)
        (2 * index) + 1
      end

      def right_child_value(parent_index)
        index = right_child_index(parent_index)
        @array[index]
      end

      def right_child_index(index)
        (2 * index) + 2
      end

      def sift_up(index)
        continue = true
        while continue && index.positive?
          parent_index = parent_index(index)
          if greater? @array[index], @array[parent_index]
            @array[parent_index], @array[index] = @array[index], @array[parent_index]
            index = parent_index
          else
            continue = false
          end
        end
      end

      def sift_down(index, replacement)
        not_leaf_index = (length / 2) - 1
        while index <= not_leaf_index
          child_index = left_greater?(index) ? left_child_index(index) : right_child_index(index)
          @array[index] = @array[child_index]
          index = child_index
        end
        sift_up_replacement(index, replacement)
      end

      def sift_up_replacement(index, replacement)
        @array[index] = replacement
        sift_up(index)
      end

      def balanced_for_left?(parent_value, parent_index)
        value = left_child_value(parent_index)
        return true if value.nil?

        less_than_or_equal?(value, parent_value)
      end

      def balanced_for_right?(parent_value, parent_index)
        value = right_child_value(parent_index)
        return true if value.nil?

        less_than_or_equal?(value, parent_value)
      end

      def left_greater?(index)
        left_value = left_child_value(index)
        right_value = right_child_value(index)
        return true if right_value.nil?

        greater? left_value, right_value
      end

      def less_than_or_equal?(a, b)
        @comparison.compare(a, b) < 1
      end

      def greater?(a, b)
        @comparison.compare(a, b).positive?
      end
    end
  end
end
