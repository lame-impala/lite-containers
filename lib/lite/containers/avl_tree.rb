# frozen_string_literal: true

require_relative 'helpers/merge'
require_relative 'avl_tree/implementation'
require_relative 'avl_tree/interfaces/key_extraction_strategy/explicit'
require_relative 'avl_tree/interfaces/key_extraction_strategy/implicit'
require_relative 'abstract/collection'
require_relative 'abstract/deque'
require_relative 'abstract/sorted_map'

module Lite
  module Containers
    class AvlTree # rubocop:disable Metrics/ClassLength
      include Abstract::Collection
      include Abstract::Deque
      include Abstract::SortedMap
      include Enumerable

      class ExplicitKey < AvlTree
        include Interfaces::KeyExtractionStrategy::Explicit
      end

      class ImplicitKey < AvlTree
        include Interfaces::KeyExtractionStrategy::Implicit
      end

      attr_reader :size

      def self.instance(type, merge: nil, **opts)
        impl = Implementation.instance(type)
        merge = Helpers::Merge.instance(merge)
        new(impl, merge, **opts)
      end

      private_class_method :new

      def initialize(impl, merge)
        @impl = impl
        @merge = merge
        reset!
      end

      def reset!
        @root = nil
        @size = 0
      end

      def key?(key)
        !find_with_finder(key, @impl::Exact).nil?
      end

      def [](key)
        find_with_finder(key, @impl::Exact)&.value
      end

      def find(key)
        find_with_finder(key, @impl::Exact)&.out
      end

      def find_or_nearest_backwards(key)
        find_with_finder(key, @impl::ExactOrNearestBackwards)&.out
      end

      def find_or_nearest_forwards(key)
        find_with_finder(key, @impl::ExactOrNearestForwards)&.out
      end

      def delete(key)
        deleted, @root = @impl.delete(key, @root)
        @size -= 1 if deleted
        deleted&.out
      end

      def each(&block)
        if block
          traverse.each(&block)
          self
        else
          traverse
        end
      end

      def reverse_each(&block)
        if block
          reverse_traverse.each(&block)
          self
        else
          reverse_traverse
        end
      end

      def traverse(from: nil, to: nil)
        Enumerator.new do |yielder|
          @impl.traverse @root, yielder, from: from, to: to
        end
      end

      def reverse_traverse(from: nil, to: nil)
        Enumerator.new do |yielder|
          @impl.reverse_traverse @root, yielder, from: from, to: to
        end
      end

      def front
        fetch_front&.out
      end

      def pop_front
        node = fetch_front
        return unless node

        delete(node.key)
        node.out
      end

      def back
        fetch_back&.out
      end

      def pop_back
        node = fetch_back
        return unless node

        delete(node.key)
        node.out
      end

      def drain!
        array = reverse_traverse.to_a
        reset!
        array
      end

      private

      def fetch_front
        return if @root.nil?

        @impl.rightmost_child(@root)
      end

      def fetch_back
        return if @root.nil?

        @impl.leftmost_child(@root)
      end

      def insert_pair(key, value)
        increment, @root = @impl.insert(@root, key, value, @merge, node_factory)
        @size += 1 if increment
        self
      end

      def find_with_finder(key, finder)
        finder.find(key, @root)
      end
    end
  end
end
