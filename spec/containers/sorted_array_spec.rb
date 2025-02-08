# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/lite/containers/sorted_array'
require_relative '../support/implements_collection'
require_relative '../support/implements_deque'
require_relative '../support/implements_enumerable'
require_relative '../support/implements_implicit_key'
require_relative '../support/implements_queue'
require_relative '../support/implements_sorted_map'

module Lite
  module Containers
    RSpec.describe SortedArray do
      let(:input_array) { [{ index: 5 }, { index: 1 }, { index: 3 }] }
      let(:index_key) { proc { |elem| elem[:index] } }
      let(:merge_strategy) { proc { |a, b| { index: a[:index], count: (a[:count] || 1) + (b[:count] || 1) } } }

      describe 'Collection implementation' do
        let(:empty_collection) { described_class.from_unsorted :max, [] }
        let(:non_empty_collection) { described_class.from_unsorted :max, [5, 1, 3] }
        let(:expected_size) { 3 }

        it_behaves_like 'implements collection'
      end

      describe 'Deque implementation' do
        let(:min_deque) { described_class.from_unsorted :min, [] }

        it_behaves_like 'implements deque'
      end

      describe 'Enumerator implementation' do
        let(:expected_accumulator) { [{ index: 1 }, { index: 3 }, { index: 5 }] }
        let(:enumerable) { described_class.from_unsorted :max, input_array, key_extractor: index_key }

        it_behaves_like 'implements enumerable'
      end

      describe 'Implicit key implementation' do
        let(:max_queue) { described_class.from_unsorted :max, [] }

        it_behaves_like 'implements implicit key'
      end

      describe 'Queue implementation' do
        let(:min_queue) { described_class.from_unsorted :min, [] }

        it_behaves_like 'implements queue'
      end

      describe 'Sorted map implementation' do
        let(:min_sorted_map) { described_class.from_unsorted :min, [] }

        it_behaves_like 'implements sorted map'
      end

      describe '#from_unsorted' do
        it 'initializes sorted array with correct order of elements' do
          sorted_array = described_class.from_unsorted :min, input_array, key_extractor: index_key
          expect(sorted_array.to_array).to eq([{ index: 5 }, { index: 3 }, { index: 1 }])
        end

        context 'in presence of duplicates' do
          let(:input_array) do
            [{ index: 3 }, { index: 5 }, { index: 3 }, { index: 1 }, { index: 1 }, { index: 3 }, { index: 1 }]
          end

          context 'with custom merge strategy' do
            it 'merges the values' do
              array = described_class.from_unsorted :min, input_array, key_extractor: index_key, merge: merge_strategy
              expected = [{ index: 5 }, { index: 3, count: 3 }, { index: 1, count: 3 }]
              expect(array.to_array).to eq(expected)
            end
          end
        end
      end

      describe '#from_sorted' do
        context 'when input is sorted' do
          let(:input_array) { [{ index: 5 }, { index: 3, id: :old }, { index: 3, id: :fresh }, { index: 1 }] }

          it 'initializes sorted array' do
            sorted_array = described_class.from_sorted :min, input_array, key_extractor: index_key
            expect(sorted_array.to_array).to eq([{ index: 5 }, { index: 3, id: :fresh }, { index: 1 }])
          end
        end

        context 'when input is unsorted' do
          it 'raises error' do
            expect { described_class.from_sorted :min, input_array, key_extractor: index_key }
              .to raise_error(Error, 'Input array is not sorted')
          end
        end
      end

      describe '#from_sorted_unsafe' do
        context 'when input is unsorted' do
          it 'initializes faulty sorted array' do
            sorted_array = described_class.from_sorted_unsafe :min, input_array, key_extractor: index_key
            expect(sorted_array.to_array).to eq([{ index: 5 }, { index: 1 }, { index: 3 }])
          end
        end
      end

      describe '#position_of' do
        let(:sorted_array) do
          described_class.from_unsorted :max, input_array, key_extractor: index_key
        end

        context 'when value not present in the array' do
          context 'when value is maximum' do
            it 'returns false, array length' do
              expect(sorted_array.position_of({ index: 7 })).to eq([false, 3])
            end
          end

          context 'when value is in between maximum and minimum' do
            it 'returns false, insert point' do
              expect(sorted_array.position_of({ index: 2 })).to eq([false, 1])
            end
          end

          context 'when value is minimum' do
            it 'returns false, 0' do
              expect(sorted_array.position_of({ index: -1 })).to eq([false, 0])
            end
          end
        end

        context 'when value present in the array' do
          it 'returns true, index' do
            expect(sorted_array.position_of({ index: 5 })).to eq([true, 2])
          end
        end
      end

      describe '#index_of' do
        let(:sorted_array) do
          described_class.from_unsorted :max, input_array, key_extractor: index_key
        end

        context 'when value is not present in the array' do
          it 'returns nil' do
            expect(sorted_array.index_of({ index: 2 })).to be_nil
          end
        end

        context 'when value is present in the array' do
          it 'returns index' do
            expect(sorted_array.index_of({ index: 5 })).to eq(2)
          end
        end
      end

      describe '#push' do
        context 'without comparator' do
          let(:array) { described_class.from_unsorted(:max, []) }

          before do
            array.push(1)
            array.push(3)
            array.push(7)
          end

          context 'item is minimum' do
            it 'adds item at the beginning' do
              array.push(-1)
              expect(array.to_array).to eq([-1, 1, 3, 7])
            end
          end

          context 'item is maximum' do
            it 'adds item at the end' do
              array.push(11)
              expect(array.to_array).to eq([1, 3, 7, 11])
            end
          end

          context 'item falls in between existing' do
            it 'inserts item into the right insert point' do
              array.push(5)
              array.push(2)
              expect(array.to_array).to eq([1, 2, 3, 5, 7])
            end
          end

          context 'item is duplicate' do
            it 'keeps unchanged order' do
              array.push(1)
              array.push(3)
              expect(array.to_array).to eq([1, 3, 7])
            end
          end
        end

        context 'with entities' do
          context 'item is duplicate' do
            context 'without merge strategy' do
              let(:array) { described_class.from_unsorted :max, input_array, key_extractor: index_key }

              it 'replaces current item' do
                array.push({ index: 1, status: :new_1 })
                array.push({ index: 3, status: :new_3 })
                array.push({ index: 5, status: :new_5 })
                expect(array.to_array.map { |element| element[:status] }).to eq(%i[new_1 new_3 new_5])
              end
            end

            context 'with custom merge strategy' do
              let(:array) do
                described_class.from_unsorted :max, input_array, key_extractor: index_key, merge: merge_strategy
              end

              it 'merges current item' do
                array.push({ index: 1 })
                array.push({ index: 3 })
                array.push({ index: 5 })
                expected = [{ index: 1, count: 2 }, { index: 3, count: 2 }, { index: 5, count: 2 }]
                expect(array.to_array).to eq(expected)
              end
            end
          end
        end

        context 'with min-type comparator' do
          let(:array) do
            described_class.from_unsorted :min, []
          end

          it 'uses comparator' do
            array.push(5)
            array.push(7)
            array.push(1)
            expect(array.to_array).to eq([7, 5, 1])
          end
        end
      end

      describe '#pop_front' do
        context 'array empty' do
          let(:array) { described_class.from_unsorted :max, [] }

          it 'leaves array empty' do
            array.pop_front
            expect(array.to_array).to be_empty
          end

          it 'returns nil' do
            expect(array.pop_front).to be_nil
          end
        end

        context 'array non empty' do
          let(:array) { described_class.from_unsorted :max, [5, 1] }

          it 'pops last item' do
            array.pop_front
            expect(array.to_array).to eq([1])
            array.pop_front
            expect(array.to_array).to be_empty
          end

          it 'returns maximum' do
            expect(array.pop_front).to eq(5)
            expect(array.pop_front).to eq(1)
            expect(array.pop_front).to be_nil
          end
        end
      end

      describe '#pop_back' do
        context 'array empty' do
          let(:array) { described_class.from_unsorted :max, [] }

          it 'leaves array empty' do
            array.pop_back
            expect(array.to_array).to be_empty
          end

          it 'returns nil' do
            expect(array.pop_back).to be_nil
          end
        end

        context 'array non empty' do
          let(:array) { described_class.from_unsorted :max, [5, 1] }

          it 'pops first item' do
            array.pop_back
            expect(array.to_array).to eq([5])
            array.pop_back
            expect(array.to_array).to be_empty
          end

          it 'returns minimum' do
            expect(array.pop_back).to eq(1)
            expect(array.pop_back).to eq(5)
            expect(array.pop_back).to be_nil
          end
        end
      end

      describe '#remove_at' do
        context 'array empty' do
          let(:array) { described_class.from_unsorted :max, [] }

          it 'leaves array empty' do
            array.remove_at(0)
            expect(array).to be_empty
          end

          it 'returns nil' do
            expect(array.remove_at(0)).to be_nil
          end
        end

        context 'array non empty' do
          let(:array) { described_class.from_unsorted :max, [5, 1, 3] }

          context 'index under zero' do
            it 'leaves array unchanged' do
              array.remove_at(-1)
              expect(array.to_array).to eq([1, 3, 5])
            end

            it 'returns nil' do
              expect(array.remove_at(-1)).to be_nil
            end
          end

          context 'index over length' do
            it 'leaves array unchanged' do
              array.remove_at(3)
              expect(array.to_array).to eq([1, 3, 5])
            end

            it 'returns nil' do
              expect(array.remove_at(3)).to be_nil
            end
          end

          context 'index is first item' do
            it 'removes first item' do
              array.remove_at(0)
              expect(array.to_array).to eq([3, 5])
            end

            it 'returns first item' do
              expect(array.remove_at(0)).to eq(1)
            end
          end

          context 'index is last item' do
            it 'removes last item' do
              array.remove_at(2)
              expect(array.to_array).to eq([1, 3])
            end

            it 'returns last item' do
              expect(array.remove_at(2)).to eq(5)
            end
          end

          context 'index is item in the middle' do
            it 'removes middle item' do
              array.remove_at(1)
              expect(array.to_array).to eq([1, 5])
            end

            it 'returns middle item' do
              expect(array.remove_at(1)).to eq(3)
            end
          end
        end
      end
    end
  end
end
