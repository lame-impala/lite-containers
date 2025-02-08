# frozen_string_literal: true

require 'spec_helper'
require 'date'
require_relative '../../lib/lite/containers/heap'
require_relative '../support/implements_collection'
require_relative '../support/implements_implicit_key'
require_relative '../support/implements_queue'

module Lite
  module Containers
    class TestHeap < Heap
      attr_reader :array

      def prefill(array)
        reset!
        array.each do |element|
          @array << element
        end
      end

      def consistent?
        (0...(length / 2)).each.all? do |index|
          consistent_at?(index)
        end
      end

      def consistent_at?(index)
        value = @array[index]
        contract_satisfied?(value, left_child_value(index)) && contract_satisfied?(value, right_child_value(index))
      end

      def contract_satisfied?(parent_value, child_value)
        return true if child_value.nil?

        less_than_or_equal?(child_value, parent_value)
      end
    end

    class TestObj
      attr_reader :id, :priority, :application_date

      def initialize(id:, priority:, application_date:)
        @id = id
        @priority = priority
        @application_date = application_date
        freeze
      end
    end

    RSpec.describe Heap do
      describe 'Collection implementation' do
        let(:empty_collection) { TestHeap.instance(:min) }
        let(:non_empty_collection) { TestHeap.instance(:max) << 5 << 1 << 3 }
        let(:expected_size) { 3 }

        it_behaves_like 'implements collection'
      end

      describe 'Implicit key implementation' do
        let(:max_queue) { TestHeap.instance :max }

        it_behaves_like 'implements implicit key'
      end

      describe 'Queue implementation' do
        let(:min_queue) { TestHeap.instance :min }

        it_behaves_like 'implements queue'
      end

      context 'fuzzy test' do
        it 'keeps consistent' do
          values = (1..100).each.to_a

          100.times do
            heap = TestHeap.instance(:min)
            shuffled = values.shuffle
            shuffled.each do |value|
              heap.push(value)
              expect(heap.consistent?).to be(true), lambda {
                "Inconsistent insert at #{value} for sequence -- #{shuffled}"
              }
            end
            expect(heap.size).to eq(100)
            sorted = []
            until heap.empty?
              sorted << heap.pop
              expect(heap.consistent?).to be(true), lambda {
                "Inconsistent pop from #{heap.array}for sequence -- #{shuffled}"
              }
            end
            expect(heap).to be_empty
          end
        end
      end

      describe 'max heap' do
        subject(:heap) { TestHeap.instance(:max) }

        describe '#replace_top' do
          it 'sifts the replacement up' do
            heap.prefill [10, 9, 8, 7, 6, 4, 3, 2, 1, 0]
            heap.replace_top(6)
            expect(heap.array).to eq([9, 7, 8, 6, 6, 4, 3, 2, 1, 0])
          end
        end

        describe '#sift_up' do
          context 'when descendant greater than parent' do
            it 'swaps values recursively' do
              heap.prefill [10, 9, 8, 7, 6, 4, 3, 2, 1, 0, 11]
              heap.send :sift_up, 10
              expect(heap.array).to eq([11, 10, 8, 7, 9, 4, 3, 2, 1, 0, 6])
            end
          end

          context 'when descendant lower or equal than parent' do
            it 'does nothing' do
              heap.prefill [10, 9, 8, 7, 6, 4, 3, 2, 1, 0, 6]
              heap.send :sift_up, 10
              expect { heap.array }.not_to change(heap, :array)
            end
          end
        end

        describe '#balanced_for_left?' do
          context 'when left child greater than parent' do
            it 'returns false' do
              heap.prefill [4, 5, 3]
              expect(heap.send(:balanced_for_left?, 4, 0)).to be(false)
            end
          end

          context 'when left child lower than parent' do
            it 'returns true' do
              heap.prefill [4, 3, 5]
              expect(heap.send(:balanced_for_left?, 4, 0)).to be(true)
            end
          end
        end

        describe '#balanced_for_right?' do
          context 'when right child greater than parent' do
            it 'returns false' do
              heap.prefill [4, 3, 5]
              expect(heap.send(:balanced_for_right?, 4, 0)).to be(false)
            end
          end

          context 'when right child lower than parent' do
            it 'returns true' do
              heap.prefill [4, 5, 3]
              expect(heap.send(:balanced_for_right?, 4, 0)).to be(true)
            end
          end
        end

        describe '#sift_down' do
          context 'when right child greater than left' do
            it 'swaps values recursively on right' do
              heap.prefill [10, 3, 8, 2, 1, 7, 6]
              heap.send :sift_down, 0, 0
              expect(heap.array).to eq([8, 3, 7, 2, 1, 0, 6])
            end
          end

          context 'when left child greater than right' do
            it 'swaps values recursively on left' do
              heap.prefill [10, 8, 3, 7, 6, 2, 1]
              heap.send :sift_down, 0, 0
              expect(heap.array).to eq([8, 7, 3, 0, 6, 2, 1])
            end
          end

          context 'when replacement greater than leaf' do
            it 'sifts down and back up to its place' do
              heap.prefill [10, 6, 5, 2, 1, 4]
              heap.send :sift_down, 0, 3
              expect(heap.array).to eq([6, 3, 5, 2, 1, 4])
            end
          end
        end

        context 'when empty' do
          it 'puts the new element on top' do
            heap.push(5)
            expect(heap.array.length).to eq(1)
            expect(heap.array[0]).to eq(5)
          end
        end

        context 'when containing one element' do
          context 'when lower on top' do
            it 'puts the new element on top' do
              heap.push(5)
              heap.push(7)
              expect(heap.array.length).to eq(2)
              expect(heap.array[0]).to eq(7)
              expect(heap.array[1]).to eq(5)
            end
          end

          context 'when upper on top' do
            it 'puts the new element on left' do
              heap.push(7)
              heap.push(5)
              expect(heap.array.length).to eq(2)
              expect(heap.array[0]).to eq(7)
              expect(heap.array[1]).to eq(5)
            end
          end
        end

        context 'when containing two elements' do
          before do
            heap.push(5)
            heap.push(7)
          end

          context 'when inserting maximum' do
            it 'puts the new element on top' do
              heap.push(9)
              expect(heap.array.length).to eq(3)
              expect(heap.array[0]).to eq(9)
              expect(heap.array[1]).to eq(5)
              expect(heap.array[2]).to eq(7)
            end
          end

          context 'when inserting minimum' do
            it 'puts the new element on right' do
              heap.push(3)
              expect(heap.array.length).to eq(3)
              expect(heap.array[0]).to eq(7)
              expect(heap.array[1]).to eq(5)
              expect(heap.array[2]).to eq(3)
            end
          end
        end

        context 'when containing four elements' do
          before do
            heap.push(7)
            heap.push(5)
            heap.push(9)
          end

          context 'when inserting maximum' do
            before do
              heap.push(11)
            end

            it 'puts the new element on top' do
              expect(heap.array.length).to eq(4)
              expect(heap.array[0]).to eq(11)
              expect(heap.array[1]).to eq(9)
              expect(heap.array[2]).to eq(7)
              expect(heap.array[3]).to eq(5)
            end

            it 'drains sorted array' do
              expect(heap.drain!).to eq([11, 9, 7, 5])
            end
          end

          context 'when inserting minimum' do
            before do
              heap.push(3)
            end

            it 'puts the new element on right' do
              expect(heap.array.length).to eq(4)
              expect(heap.array[0]).to eq(9)
              expect(heap.array[1]).to eq(5)
              expect(heap.array[2]).to eq(7)
              expect(heap.array[3]).to eq(3)
            end

            it 'pops in correct order' do
              expect(heap.pop).to eq(9)
              expect(heap.length).to eq(3)
              expect(heap.pop).to eq(7)
              expect(heap.length).to eq(2)
              expect(heap.pop).to eq(5)
              expect(heap.length).to eq(1)
              expect(heap.pop).to eq(3)
              expect(heap.length).to eq(0)
            end

            it 'drains sorted array' do
              expect(heap.drain!).to eq([9, 7, 5, 3])
            end
          end
        end
      end

      describe 'min heap' do
        subject(:heap) { TestHeap.instance(:min) }

        describe '#replace_top' do
          it 'sifts the replacement up' do
            heap.prefill [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            heap.replace_top(4)
            expect(heap.array).to eq([1, 3, 2, 4, 4, 5, 6, 7, 8, 9])
          end
        end

        context 'when heap contains three elements' do
          before do
            heap << 7 << 5 << 9
          end

          context 'when inserting maximum' do
            before do
              heap.push(3)
            end

            it 'puts the new element on top' do
              expect(heap.array.length).to eq(4)
              expect(heap.array[0]).to eq(3)
              expect(heap.array[1]).to eq(5)
              expect(heap.array[2]).to eq(9)
              expect(heap.array[3]).to eq(7)
            end

            it 'drains sorted array' do
              expect(heap.drain!).to eq([3, 5, 7, 9])
            end
          end

          context 'when inserting minimum' do
            before do
              heap.push(11)
            end

            it 'puts the new element on right' do
              expect(heap.array.length).to eq(4)
              expect(heap.array[0]).to eq(5)
              expect(heap.array[1]).to eq(7)
              expect(heap.array[2]).to eq(9)
              expect(heap.array[3]).to eq(11)
            end

            it 'drains sorted array' do
              expect(heap.drain!).to eq([5, 7, 9, 11])
            end
          end
        end
      end

      describe 'heap with key extractor' do
        subject(:heap) do
          key_extractor = proc { |elem| [-elem.priority, elem.application_date] }
          TestHeap.instance(type, key_extractor: key_extractor)
        end

        before do
          heap << TestObj.new(id: 1, priority: 1, application_date: Date.parse('2022-05-15'))
          heap << TestObj.new(id: 2, priority: 2, application_date: Date.parse('2022-03-19'))
          heap << TestObj.new(id: 3, priority: 1, application_date: Date.parse('2022-07-02'))
          heap << TestObj.new(id: 4, priority: 2, application_date: Date.parse('2022-10-25'))
          heap << TestObj.new(id: 5, priority: 3, application_date: Date.parse('2022-10-25'))
        end

        context 'with :max type' do
          let(:type) { :max }

          it 'orders elements using the correct comparator' do
            ordered = heap.drain!
            expect(ordered.map(&:id)).to eq([3, 1, 4, 2, 5])
          end
        end

        context 'with :min type' do
          let(:type) { :min }

          it 'orders elements using the correct comparator' do
            ordered = heap.drain!
            expect(ordered.map(&:id)).to eq([5, 2, 4, 1, 3])
          end
        end
      end
    end
  end
end
