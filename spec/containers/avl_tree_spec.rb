# frozen_string_literal: true

require_relative '../support/avl_tree/helper'
require_relative '../support/avl_tree/test_tree'
require_relative '../../lib/lite/containers/avl_tree'
require_relative '../support/implements_collection'
require_relative '../support/implements_deque'
require_relative '../support/implements_enumerable'
require_relative '../support/implements_implicit_key'
require_relative '../support/implements_queue'
require_relative '../support/implements_sorted_map'

module Lite
  module Containers
    RSpec.describe AvlTree do
      let(:type) { :max }
      let(:prepopulated) do
        tree = TestTree::ExplicitKey.instance(type)
        tree.insert(3, :three)
            .insert(5, :five)
            .insert(1, :one)
            .insert(8, :eight)
      end

      describe 'Collection implementation' do
        let(:empty_collection) { TestTree::ImplicitKey.instance :max }
        let(:non_empty_collection) { TestTree::ImplicitKey.instance(:max) << 5 << 1 << 3 }
        let(:expected_size) { 3 }

        it_behaves_like 'implements collection'
      end

      describe 'Deque implementation' do
        let(:min_deque) { TestTree::ImplicitKey.instance :min }

        it_behaves_like 'implements deque'
      end

      describe 'Enumerator implementation' do
        context 'with explicit key' do
          let(:expected_accumulator) { [[1, :one], [3, :three], [5, :five], [8, :eight]] }
          let(:enumerable) { prepopulated }

          it_behaves_like 'implements enumerable'
        end

        context 'with implicit key' do
          let(:expected_accumulator) { [8, 5, 3, 1] }
          let(:enumerable) { TestTree::ImplicitKey.instance(:min) << 3 << 5 << 1 << 8 }

          it_behaves_like 'implements enumerable'
        end
      end

      describe 'Implicit queue implementation' do
        let(:max_queue) { TestTree::ImplicitKey.instance :max }

        it_behaves_like 'implements implicit key'
      end

      describe 'Queue implementation' do
        let(:min_queue) { TestTree::ImplicitKey.instance :min }

        it_behaves_like 'implements queue'
      end

      describe 'Sorted map implementation' do
        let(:min_sorted_map) { TestTree::ImplicitKey.instance :min }

        it_behaves_like 'implements sorted map'
      end

      context 'fuzzy test' do
        it 'keeps consistent' do
          keys = (1..100).each.to_a

          100.times do
            t = TestTree::ImplicitKey.instance(rand(2) == 0 ? :max : :min)
            shuffled = keys.shuffle
            shuffled.each do |key|
              t.push(key)
              expect(t.consistent?).to be(true), -> { "Inconsistent insert at #{key} for sequence -- #{shuffled}" }
            end
            expect(t.size).to eq(100)
            shuffled = keys.shuffle
            shuffled.each do |key|
              deleted_key, _deleted_value = t.delete(key)
              expect(deleted_key).to eq(key)
              expect(t.consistent?).to be(true), -> { "Inconsistent delete at #{key} for sequence -- #{shuffled}" }
            end
            expect(t).to be_empty
          end
        end
      end

      describe '#find' do
        context 'when key is present' do
          it 'finds the value' do
            expect(prepopulated.find(5)).to eq([5, :five])
          end
        end

        context 'when key is not present' do
          it 'finds nothing' do
            expect(prepopulated.find(4)).to be_nil
          end
        end
      end

      context 'when type is max' do
        describe '#find_or_nearest_backwards' do
          context 'when key is present' do
            it 'finds exact match' do
              expect(prepopulated.find_or_nearest_backwards(5)).to eq([5, :five])
            end
          end

          context 'when key is not present' do
            context 'when match present' do
              it 'finds nearest match' do
                expect(prepopulated.find_or_nearest_backwards(4)).to eq([3, :three])
              end
            end

            context 'when no match present' do
              it 'finds nothing' do
                expect(prepopulated.find_or_nearest_backwards(0)).to be_nil
              end
            end
          end
        end

        describe '#find_or_nearest_forwards' do
          context 'when key is present' do
            it 'finds exact match' do
              expect(prepopulated.find_or_nearest_forwards(3)).to eq([3, :three])
            end
          end

          context 'when key is not present' do
            context 'when match present' do
              it 'finds nearest match' do
                expect(prepopulated.find_or_nearest_forwards(4)).to eq([5, :five])
              end
            end

            context 'when no match present' do
              it 'finds nothing' do
                expect(prepopulated.find_or_nearest_forwards(9)).to be_nil
              end
            end
          end
        end
      end

      context 'when type is min' do
        let(:type) { :min }

        describe '#find' do
          context 'when key is present' do
            it 'finds the value' do
              expect(prepopulated.find(5)).to eq([5, :five])
            end
          end

          context 'when key is not present' do
            it 'finds nothing' do
              expect(prepopulated.find(4)).to be_nil
            end
          end
        end

        describe '#find_or_nearest_backwards' do
          context 'when key is present' do
            it 'finds exact match' do
              expect(prepopulated.find_or_nearest_backwards(3)).to eq([3, :three])
            end
          end

          context 'when key is not present' do
            context 'when match present' do
              it 'finds nearest match' do
                expect(prepopulated.find_or_nearest_backwards(4)).to eq([5, :five])
              end
            end

            context 'when no match present' do
              it 'finds nothing' do
                expect(prepopulated.find_or_nearest_backwards(9)).to be_nil
              end
            end
          end
        end

        describe '#find_or_nearest_forwards' do
          context 'when key is present' do
            it 'finds exact match' do
              expect(prepopulated.find_or_nearest_forwards(5)).to eq([5, :five])
            end
          end

          context 'when key is not present' do
            context 'when match present' do
              it 'finds nearest match' do
                expect(prepopulated.find_or_nearest_forwards(4)).to eq([3, :three])
              end
            end

            context 'when no match present' do
              it 'finds nothing' do
                expect(prepopulated.find_or_nearest_forwards(0)).to be_nil
              end
            end
          end
        end
      end

      describe '#traverse' do
        context 'when type is max' do
          context 'with no limits' do
            it 'traverses whole tree' do
              array = prepopulated.traverse.map(&:first).to_a
              expect(array).to eq([1, 3, 5, 8])
            end
          end

          context 'with up from limit' do
            it 'traverses up from limit' do
              array = prepopulated.traverse(from: 3).map(&:first).to_a
              expect(array).to eq([3, 5, 8])
            end
          end

          context 'with up to limit' do
            it 'traverses up to limit' do
              array = prepopulated.traverse(to: 5).map(&:first).to_a
              expect(array).to eq([1, 3, 5])
            end
          end

          context 'with up from and to limits' do
            it 'traverses within limits' do
              array = prepopulated.traverse(from: 3, to: 5).map(&:first).to_a
              expect(array).to eq([3, 5])
            end
          end
        end

        describe '#reverse_traverse' do
          context 'with no limits' do
            it 'traverses whole tree' do
              array = prepopulated.reverse_traverse.map(&:first).to_a
              expect(array).to eq([8, 5, 3, 1])
            end
          end

          context 'with down from limit' do
            it 'traverses down from limit' do
              array = prepopulated.reverse_traverse(from: 5).map(&:first).to_a
              expect(array).to eq([5, 3, 1])
            end
          end

          context 'with down to limit' do
            it 'traverses down to limit' do
              array = prepopulated.reverse_traverse(to: 3).map(&:first).to_a
              expect(array).to eq([8, 5, 3])
            end
          end

          context 'with down from and to limits' do
            it 'traverses within limits' do
              array = prepopulated.reverse_traverse(from: 5, to: 3).map(&:first).to_a
              expect(array).to eq([5, 3])
            end
          end
        end

        context 'when type is min' do
          let(:type) { :min }

          context 'with no limits' do
            it 'traverses whole tree' do
              array = prepopulated.traverse.map(&:first).to_a
              expect(array).to eq([8, 5, 3, 1])
            end
          end

          context 'with down from limit' do
            it 'traverses up from limit' do
              array = prepopulated.traverse(from: 5).map(&:first).to_a
              expect(array).to eq([5, 3, 1])
            end
          end

          context 'with down to limit' do
            it 'traverses up to limit' do
              array = prepopulated.traverse(to: 3).map(&:first).to_a
              expect(array).to eq([8, 5, 3])
            end
          end

          context 'with down from and to limits' do
            it 'traverses within limits' do
              array = prepopulated.traverse(from: 5, to: 3).map(&:first).to_a
              expect(array).to eq([5, 3])
            end
          end

          describe '#reverse_traverse' do
            context 'with no limits' do
              it 'traverses whole tree' do
                array = prepopulated.reverse_traverse.map(&:first).to_a
                expect(array).to eq([1, 3, 5, 8])
              end
            end

            context 'with up to limit' do
              it 'traverses up to limit' do
                array = prepopulated.reverse_traverse(from: 3).map(&:first).to_a
                expect(array).to eq([3, 5, 8])
              end
            end

            context 'with up from limit' do
              it 'traverses up to limit' do
                array = prepopulated.reverse_traverse(to: 5).map(&:first).to_a
                expect(array).to eq([1, 3, 5])
              end
            end

            context 'with up from and to limits' do
              it 'traverses within limits' do
                array = prepopulated.reverse_traverse(from: 3, to: 5).map(&:first).to_a
                expect(array).to eq([3, 5])
              end
            end
          end
        end
      end

      describe '#back' do
        context 'with empty tree' do
          it 'returns nil' do
            front = TestTree::ImplicitKey.instance(:max).back
            expect(front).to be_nil
          end
        end

        context 'with non-empty tree' do
          it 'returns back' do
            front = prepopulated.back
            expect(front).to eq([1, :one])
          end
        end
      end

      describe '#pop_back' do
        context 'with empty tree' do
          it 'returns nil' do
            element = TestTree::ImplicitKey.instance(:max).pop_back
            expect(element).to be_nil
          end
        end

        context 'with non-empty tree' do
          it 'returns back' do
            element = prepopulated.pop_back
            expect(element).to eq([1, :one])
          end

          it 'decrements size' do
            expect do
              prepopulated.pop_back
            end.to change(prepopulated, :size).by(-1)
          end
        end
      end

      describe '#front' do
        context 'with empty tree' do
          it 'returns nil' do
            element = TestTree::ImplicitKey.instance(:max).front
            expect(element).to be_nil
          end
        end

        context 'with non-empty tree' do
          it 'returns front' do
            element = prepopulated.front
            expect(element).to eq([8, :eight])
          end
        end
      end

      describe '#insert' do
        context 'when inserting non-existent key' do
          it 'inserts the value' do
            expect { prepopulated.insert(4, :four) }.to change { prepopulated.find(4) }
              .from(nil)
              .to([4, :four])
          end

          it 'increments size' do
            expect { prepopulated.insert(4, :four) }.to change(prepopulated, :size).from(4).to(5)
          end
        end

        context 'when inserting existent key' do
          it 'inserts the value' do
            expect { prepopulated.insert(3, :THREE) }.to change { prepopulated.find(3) }
              .from([3, :three])
              .to([3, :THREE])
          end

          it "doesn't increment size" do
            expect { prepopulated.insert(3, :THREE) }.not_to change(prepopulated, :size)
          end
        end
      end

      describe '#delete' do
        context 'when deleting non-existent key' do
          it 'returns nil' do
            expect(prepopulated.delete(4)).to be_nil
          end

          it "doesn't decrement size" do
            expect { prepopulated.delete(4) }.not_to change(prepopulated, :size)
          end
        end

        context 'when deleting existent key' do
          it 'returns true and deleted value' do
            expect(prepopulated.delete(3)).to eq([3, :three])
          end

          it 'deletes the key' do
            expect { prepopulated.delete(3) }
              .to change { prepopulated.find(3) }
              .from([3, :three])
              .to(nil)
          end

          it 'decrements size' do
            expect { prepopulated.delete(3) }.to change(prepopulated, :size).from(4).to(3)
          end
        end
      end
    end
  end
end
