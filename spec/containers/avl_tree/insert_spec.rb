# frozen_string_literal: true

require_relative '../../support/avl_tree/helper'
require_relative '../../support/avl_tree/test_tree'
require_relative '../../../lib/lite/containers/helpers/merge'

module Lite
  module Containers
    class AvlTree
      module InsertImpl
        extend Balance
        extend Insert

        def self.compare(a, b)
          Helpers::Comparison::Max.compare(a, b)
        end
      end

      describe Insert do
        let(:merge) { Helpers::Merge.instance(:replace) }

        context 'with balanced node' do
          include_context 'balanced node'

          context 'when inserting to existing key' do
            it 'replaces value at target node' do
              expect do
                InsertImpl.insert(balanced, 12, :NEW, merge, Node)
              end.to change(balanced.left.right, :value).from('bax').to(:NEW)
            end

            it "doesn't affect height" do
              increment, root = InsertImpl.insert(balanced, 12, :NEW, merge, Node)
              expect(increment).to be(false)
              result = TestTree.consistent?(root, :max)
              expect(result).to eq([true, 3, 7])
            end
          end

          context 'when inserting a new key' do
            it 'inserts a new node' do
              InsertImpl.insert(balanced, 14, :NEW, merge, Node)
              expect(balanced.left.right.right.value).to eq(:NEW)
            end

            it 'increments height' do
              increment, root = InsertImpl.insert(balanced, 14, :NEW, merge, Node)
              expect(increment).to be(true)
              result = TestTree.consistent?(root, :max)
              expect(result).to eq([true, 4, 8])
            end
          end
        end

        context 'with right right unbalanced node' do
          include_context 'right right unbalanced node'

          it 'rebalances the tree' do
            increment, root = InsertImpl.insert(balanced, 9, 'qaz', merge, Node)
            expect(increment).to be(true)
            balanced, height = TestTree.consistent?(root, :max)
            expect(balanced).to be(true)
            expect(height).to eq(3)

            expected = {
              k: 7, h: 3,
              l: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } },
              r: { k: 8, h: 2, r: { k: 9, h: 1 } }
            }
            expect(root).to have_structure(expected)
          end
        end

        context 'with left left unbalanced node' do
          include_context 'left left unbalanced node'

          it 'rebalances the tree' do
            increment, root = InsertImpl.insert(balanced, 1, 'qaz', merge, Node)
            expect(increment).to be(true)
            balanced, height = TestTree.consistent?(root, :max)
            expect(balanced).to be(true)
            expect(height).to eq(3)

            expected = {
              k: 3, h: 3,
              l: { k: 2, h: 2, l: { k: 1, h: 1 } },
              r: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } }
            }
            expect(root).to have_structure(expected)
          end
        end

        context 'with right left unbalanced node' do
          include_context 'right left unbalanced node'

          it 'rebalances the tree' do
            increment, root = InsertImpl.insert(balanced, 6, 'baz', merge, Node)
            expect(increment).to be(true)
            balanced, height = TestTree.consistent?(root, :max)
            expect(balanced).to be(true)
            expect(height).to eq(3)

            expected = {
              k: 7, h: 3,
              l: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } },
              r: { k: 8, h: 2, r: { k: 9, h: 1 } }
            }
            expect(root).to have_structure(expected)
          end
        end

        context 'with left right unbalanced node' do
          include_context 'left right unbalanced node'

          it 'rebalances the tree' do
            increment, root = InsertImpl.insert(balanced, 4, 'qaz', merge, Node)
            expect(increment).to be(true)
            balanced, height = TestTree.consistent?(root, :max)
            expect(balanced).to be(true)
            expect(height).to eq(3)

            expected = {
              k: 3, h: 3,
              l: { k: 2, h: 2, l: { k: 1, h: 1 } },
              r: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } }
            }
            expect(root).to have_structure(expected)
          end
        end
      end
    end
  end
end
