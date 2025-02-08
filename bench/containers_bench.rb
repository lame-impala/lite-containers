# frozen_string_literal: true

require 'benchmark'
require_relative '../lib/lite/containers/sorted_array'
require_relative '../lib/lite/containers/heap'
require_relative '../lib/lite/containers/avl_tree'

module Lite
  module Containers
    module AbstractBench
      def measure(n)
        warm_up
        subjects = populate(n)
        output_to_sorted_array(subjects)
      end

      def warm_up
        puts '  warm up ...'

        100.times do
          subject = initial_subject
          1000.times do
            insert_single(subject, rand(1000))
            output(subject)
          end
        end
      end

      def populate(n)
        puts "\n  populate ..."

        subjects = []
        times = 100_000 / n

        result = Benchmark.measure do
          times.times do
            subject = initial_subject
            n.times do
              insert_single(subject, rand(n))
            end
            subjects << subject
          end
        end
        puts result
        subjects
      end

      def output_to_sorted_array(subjects)
        puts "\n  output from #{subjects.length} subjects to sorted array of #{subjects.first&.length || 0}"

        result = Benchmark.measure do
          subjects.each do |subject|
            output(subject)
          end
        end
        puts result
      end
    end

    module ArrayBench
      extend AbstractBench

      def self.initial_subject
        SortedArray.from_sorted_unsafe(:max, [])
      end

      def self.insert_single(array, value)
        array << value
      end

      def self.output(array)
        array.to_array
      end
    end

    module HeapBench
      extend AbstractBench

      def self.initial_subject
        Heap.instance(:max)
      end

      def self.insert_single(heap, value)
        heap << value
      end

      def self.output(heap)
        heap.drain!
      end
    end

    module AvlTreeBench
      extend AbstractBench

      def self.initial_subject
        AvlTree::ExplicitKey.instance :max
      end

      def self.insert_single(tree, value)
        tree.insert(value, nil)
      end

      def self.output(tree)
        tree.traverse.to_a
      end
    end
  end
end

N = 10_000

puts "------------- ARRAY #{N} -------------"
Lite::Containers::ArrayBench.measure(N)
puts '--------------------------------------'
puts "------------- HEAP #{N} --------------"
Lite::Containers::HeapBench.measure(N)
puts '--------------------------------------'
puts "------------- AVL #{N} ---------------"
Lite::Containers::AvlTreeBench.measure(N)
puts '--------------------------------------'

# https://stackoverflow.com/questions/6531543/efficient-implementation-of-binary-heaps
