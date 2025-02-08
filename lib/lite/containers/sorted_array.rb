# frozen_string_literal: true

require_relative 'error'
require_relative 'helpers/comparison'
require_relative 'helpers/merge'
require_relative 'sorted_array/binary_search'
require_relative 'abstract/collection'
require_relative 'abstract/deque'
require_relative 'abstract/implicit_key'
require_relative 'abstract/sorted_map'

module Lite
  module Containers
    class SortedArray # rubocop:disable Metrics/ClassLength
      include Abstract::Collection
      include Enumerable
      include Abstract::ImplicitKey
      include Abstract::Deque
      include Abstract::SortedMap

      class Error < Containers::Error; end

      attr_reader :comparator

      def self.from_unsorted(type, array, key_extractor: nil, merge: nil)
        comparison = comparison(type, key_extractor)
        sorted = array.sort { |a, b| comparison.compare(a, b) }
        construct(sorted, comparison, merge)
      end

      def self.from_sorted(type, array, key_extractor: nil, merge: nil)
        comparison = comparison(type, key_extractor)
        sorted = ensure_sorted!(array, comparison)
        construct(sorted, comparison, merge)
      end

      def self.from_sorted_unsafe(type, sorted, key_extractor: nil, merge: nil)
        comparison = comparison(type, key_extractor)
        construct(sorted, comparison, merge)
      end

      def self.comparison(type, key_extractor)
        Helpers::Comparison.instance(type, key_extractor: key_extractor)
      end

      def self.construct(sorted, comparison, merge)
        merge = Helpers::Merge.instance(merge)
        deduplicated = handle_duplicates(sorted, comparison, merge)
        new(deduplicated, comparison, merge)
      end

      def self.handle_duplicates(array, comparison, merge)
        chunks = array.chunk_while { |a, b| comparison.compare(a, b).zero? }
        chunks.map do |chunk|
          first, *rest = chunk
          next first if rest.empty?

          rest.reduce(first) do |last, current|
            merge.merge(last, current)
          end
        end
      end

      def self.ensure_sorted!(array, comparison)
        array.each_cons(2) do |a, b|
          raise Error, 'Input array is not sorted' unless comparison.compare(a, b) < 1
        end
        array
      end

      private_class_method :new, :comparison, :construct, :handle_duplicates, :ensure_sorted!

      def initialize(array, comparison, merge)
        @comparison = comparison
        @merge = merge
        @array = array.freeze
      end

      def drain!
        array = @array
        @array = []
        array.reverse
      end

      def size
        @array.size
      end

      def index_of(item)
        found, index = position_of(item)
        return unless found

        index
      end

      def position_of(item)
        BinarySearch.find_position(@array, comparison.for_item(item))
      end

      def each(&block)
        if block
          array.each(&block)
          self
        else
          array.each
        end
      end

      def to_array
        array
      end

      def front
        array.last
      end

      def pop_front
        *rest, item = @array
        @array = rest.freeze
        item
      end

      def back
        array.first
      end

      def pop_back
        item, *rest = @array
        @array = rest.freeze
        item
      end

      def [](index)
        array[index]
      end

      def key?(key)
        found, = BinarySearch.position_of(@array, key, comparison: comparison)
        found
      end

      def find(key)
        found, index = BinarySearch.position_of(@array, key, comparison: comparison)
        self[index] if found
      end

      def find_or_nearest_backwards(key)
        found, position = BinarySearch.position_of(@array, key, comparison: comparison)
        return self[position] if found
        return if position.zero?

        self[position - 1]
      end

      def find_or_nearest_forwards(key)
        _, position = BinarySearch.position_of(@array, key, comparison: comparison)
        self[position]
      end

      def remove_at(index)
        return if index.negative?

        before = array[0...index]
        to_remove = array[index]
        after = array[(index + 1)..]
        @array = [*before, *after].freeze
        to_remove
      end

      def push(item)
        found, position = position_of(item)
        item = handle_duplicate(position, item) if found
        before = array[0...position]
        keep_from = found ? position + 1 : position
        after = array[keep_from..]
        @array = [*before, item, *after].freeze
      end

      private

      attr_reader :array, :comparison, :merge

      def handle_duplicate(index, fresh)
        merge.merge(array[index], fresh)
      end
    end
  end
end
