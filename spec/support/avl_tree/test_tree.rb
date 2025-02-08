# frozen_string_literal: true

require_relative '../../../lib/lite/containers/avl_tree'

module Lite
  module Containers
    module TestTree
      class ExplicitKey < AvlTree::ExplicitKey
        include TestTree
      end

      class ImplicitKey < AvlTree::ImplicitKey
        include TestTree
      end

      attr_reader :root

      def display_format
        self.class.display_format(@root, 0)
      end

      def type
        if @impl == AvlTree::Implementation::Min then :min
        elsif @impl == AvlTree::Implementation::Max then :max
        else
          raise "Unexpected implementation: #{@impl.name}"
        end
      end

      def consistent?
        consistent, _, real_size = TestTree.consistent?(@root, type)
        consistent && real_size == @size
      end

      def self.consistent?(node, type)
        sorted, real_size = sorted?(node, type)
        balanced, real_height = balanced?(node)
        [sorted && balanced, real_height, real_size]
      end

      def self.sorted?(node, type)
        array = to_array(node)
        sorted = array.sort_by(&:first)
        sorted.reverse! if type == :min
        [array == sorted, array.length]
      end

      def self.to_array(node, collector = [])
        return collector if node.nil?

        to_array(node.left, collector)
        collector << [node.key, node.value]
        to_array(node.right, collector)
      end

      def self.balanced?(node)
        return true, 0 if node.nil?

        left_balanced, left_height = balanced?(node.left)
        right_balanced, right_height = balanced?(node.right)
        real_height = [left_height, right_height].max + 1
        self_balanced = (right_height - left_height).abs < 2 && node.height == real_height
        balanced = left_balanced && right_balanced && self_balanced
        [balanced, real_height]
      end

      def self.display_format(node, height, side: nil)
        return if node.nil?

        puts "#{'  ' * height}#{side || :_}:#{node.inspect}"
        display_format(node.left, height + 1, side: :L)
        display_format(node.right, height + 1, side: :R)
      end
    end
  end
end
