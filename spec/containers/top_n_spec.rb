# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/lite/containers/top_n/avl_tree'
require_relative '../../lib/lite/containers/top_n/heap'
require_relative '../support/top_n/uses_key_extractor'
require_relative '../support/top_n/limits_number_of_entries'
require_relative '../support/top_n/applies_filter'
require_relative '../support/top_n/has_merge_capability'
require_relative '../support/top_n/has_deque_properties'
require_relative '../support/implements_collection'

module Lite
  module Containers
    RSpec.describe TopN do
      context 'with AVL tree backend' do
        let(:backend) { :avl_tree }

        it_behaves_like 'uses key extractor'
        it_behaves_like 'limits number of entries'
        it_behaves_like 'applies filter'
        it_behaves_like 'has merge capability'
        it_behaves_like 'has deque properties'
      end

      context 'with heap backend' do
        let(:backend) { :heap }

        it_behaves_like 'uses key extractor'
        it_behaves_like 'limits number of entries'
        it_behaves_like 'applies filter'
      end

      describe 'Collection implementation' do
        let(:empty_collection) { described_class.instance(:heap, :max) }
        let(:non_empty_collection) do
          collection = described_class.instance(:heap, :max)
          collection << 5 << 1 << 3
        end
        let(:expected_size) { 3 }

        it_behaves_like 'implements collection'
      end

      context 'with filter' do
        it 'drops items failing the filter' do
          queue = described_class.instance(:avl_tree, :max, filter: proc { |item| item < 3 })
          (1..5).to_a.shuffle.each do |item|
            queue.push(item)
          end
          expect(queue.drain!).to eq([2, 1])
        end
      end

      context 'with non-positive limit' do
        it 'raises' do
          expect do
            described_class.instance(:avl_tree, :max, limit: 0)
          end.to raise_error(described_class::Error, "Expected positive integer or nil for limit, got '0'")
        end
      end

      context 'with key extractor and merge' do
        let(:key_extractor) { proc { |element| -element[:index] } }
        let(:merge) { proc { |a, b| { index: a[:index], count: a[:count] + b[:count] } } }
        let(:item3) { { index: 3, count: 1 } }
        let(:item5) { { index: 5, count: 1 } }
        let(:item1) { { index: 1, count: 1 } }

        context 'without limit' do
          let(:queue) do
            described_class.instance(
              :avl_tree,
              :max,
              key_extractor: key_extractor,
              merge: merge
            )
          end

          context 'with empty queue' do
            describe '#push' do
              it 'pushes item' do
                item = { index: 5, count: 1 }
                queue.push(item)
                expect(queue.drain!).to eq([item])
              end
            end

            describe '#pop_back' do
              it 'returns nil' do
                expect(queue.pop_back).to be_nil
              end
            end

            describe '#pop_front' do
              it 'returns nil' do
                expect(queue.pop_front).to be_nil
              end
            end
          end

          context 'with non-empty queue' do
            before do
              [item5, item1, item3].each do |item|
                queue.push(item)
              end
            end

            describe '#push' do
              context 'no collision' do
                it 'pushes item' do
                  item7 = { index: 7, count: 1 }
                  dropped = queue.push(item7)
                  expect(dropped).to eq([])
                  expect(queue.drain!).to eq([item1, item3, item5, item7])
                end
              end

              context 'with collision' do
                it 'merges item' do
                  item = { index: 3, count: 1 }
                  dropped = queue.push(item)
                  expect(dropped).to eq([])
                  item3prime = { index: 3, count: 2 }
                  expect(queue.drain!).to eq([item1, item3prime, item5])
                end
              end
            end

            describe '#pop_back' do
              it 'returns minimum' do
                expect(queue.pop_back).to eq(item5)
              end
            end

            describe '#pop_front' do
              it 'returns maximum' do
                expect(queue.pop_front).to eq(item1)
              end
            end
          end
        end

        context 'with limit' do
          let(:queue) do
            described_class.instance(
              :avl_tree,
              :max,
              limit: 3,
              key_extractor: proc { |element| element[:index] },
              merge: proc { |a, b| { index: a[:index], count: (a[:count] || 1) + (b[:count] || 1) } }
            )
          end

          context 'queue non-empty' do
            before do
              [item5, item1, item3].each do |item|
                queue.push(item)
              end
            end

            describe '#push' do
              context 'no collision' do
                it 'pushes item and shrinks' do
                  item2 = { index: 2, count: 1 }
                  dropped = queue.push(item2)
                  expect(dropped).to eq([item1])
                  expect(queue.drain!).to eq([item5, item3, item2])
                end
              end

              context 'with collisions' do
                let(:expected_result) { [{ index: 5, count: 2 }, { index: 3, count: 2 }, { index: 1, count: 2 }] }

                it 'merges items' do
                  queue.push({ index: 3 })
                  queue.push({ index: 5 })
                  queue.push({ index: 1 })
                  expect(queue.drain!).to eq(expected_result)
                end
              end
            end
          end
        end
      end
    end
  end
end
