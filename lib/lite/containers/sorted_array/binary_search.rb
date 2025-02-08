# frozen_string_literal: true

require_relative '../helpers/comparison'

module Lite
  module Containers
    class SortedArray
      module BinarySearch
        def self.position_of(sorted_array, key, comparison: Helpers::Comparison::Max)
          comparator = comparison.for_key(key)
          find_position(sorted_array, comparator)
        end

        def self.find_position(sorted_array, comparator)
          upper = sorted_array.length
          lower = 0
          found = false
          index = lower

          while !found && upper > lower
            index = midpoint(lower, upper)
            candidate = sorted_array[index]
            result = comparator.call(candidate)
            if result.zero?
              found = true
            elsif result.negative?
              upper = index
            else
              index += 1
              lower = index
            end
          end
          [found, index]
        end

        def self.midpoint(lower, upper)
          ((upper - lower) / 2) + lower
        end
      end
    end
  end
end
