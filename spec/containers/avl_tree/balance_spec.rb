# frozen_string_literal: true

require_relative '../../support/avl_tree/helper'
require_relative '../../../lib/lite/containers/avl_tree/balance'

module Lite
  module Containers
    class AvlTree
      module BalanceImpl
        extend Balance
      end

      RSpec.describe Balance do
        context 'with balanced node' do
          include_context 'balanced node'

          describe '::balance_factor' do
            it 'reports 0' do
              expect(BalanceImpl.balance_factor(balanced)).to eq(0)
            end
          end

          describe '::rebalance' do
            it 'updates node height' do
              balanced.height = 2
              expect do
                new_root = BalanceImpl.rebalance(balanced)
                expect(new_root.key).to eq(balanced.key)
              end.to change(balanced, :height).from(2).to(3)
            end
          end
        end

        context 'with right right unbalanced node' do
          include_context 'right right unbalanced node'

          describe '::balance_factor' do
            it 'reports 2' do
              expect(BalanceImpl.balance_factor(right_right_unbalanced)).to eq(2)
            end
          end

          describe '::rebalance' do
            it 'calls .rotate_left' do
              allow(BalanceImpl).to receive(:rotate_left).and_call_original
              BalanceImpl.rebalance(right_right_unbalanced)
              expect(BalanceImpl).to have_received(:rotate_left)
            end
          end

          describe '::rotate_left' do
            it 'rebalances structure correctly' do
              new_root = BalanceImpl.rotate_left(right_right_unbalanced)
              expected = {
                k: 7, h: 3,
                l: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } },
                r: { k: 8, h: 2, r: { k: 9, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        context 'with left left unbalanced node' do
          include_context 'left left unbalanced node'

          describe '::balance_factor' do
            it 'reports -2' do
              expect(BalanceImpl.balance_factor(left_left_unbalanced)).to eq(-2)
            end
          end

          describe '::rebalance' do
            it 'calls .rotate_right' do
              allow(BalanceImpl).to receive(:rotate_right).and_call_original
              BalanceImpl.rebalance(left_left_unbalanced)
              expect(BalanceImpl).to have_received(:rotate_right)
            end
          end

          describe '::rotate_right' do
            it 'rebalances structure correctly' do
              new_root = BalanceImpl.rotate_right(left_left_unbalanced)
              expected = {
                k: 3, h: 3,
                l: { k: 2, h: 2, l: { k: 1, h: 1 } },
                r: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        context 'with right left unbalanced node' do
          include_context 'right left unbalanced node'

          describe '::balance_factor' do
            it 'reports 2' do
              expect(BalanceImpl.balance_factor(right_left_unbalanced)).to eq(2)
            end
          end

          describe '::rebalance' do
            it 'calls .rotate_left_right' do
              allow(BalanceImpl).to receive(:rotate_right_left).and_call_original
              BalanceImpl.rebalance(right_left_unbalanced)
              expect(BalanceImpl).to have_received(:rotate_right_left)
            end
          end

          describe '::rotate_right_left' do
            it 'rebalances structure correctly' do
              new_root = BalanceImpl.rotate_right_left(right_left_unbalanced)
              expected = {
                k: 7, h: 3,
                l: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } },
                r: { k: 8, h: 2, r: { k: 9, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        context 'with left right unbalanced node' do
          include_context 'left right unbalanced node'

          describe '::balance_factor' do
            it 'reports -2' do
              expect(BalanceImpl.balance_factor(left_right_unbalanced)).to eq(-2)
            end
          end

          describe '::rebalance' do
            it 'calls .rotate_left_right' do
              allow(BalanceImpl).to receive(:rotate_left_right).and_call_original
              BalanceImpl.rebalance(left_right_unbalanced)
              expect(BalanceImpl).to have_received(:rotate_left_right)
            end
          end

          describe '::rotate_left_right' do
            it 'rebalances structure correctly' do
              new_root = BalanceImpl.rotate_left_right(left_right_unbalanced)
              expected = {
                k: 3, h: 3,
                l: { k: 2, h: 2, l: { k: 1, h: 1 } },
                r: { k: 5, h: 2, l: { k: 4, h: 1 }, r: { k: 6, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        describe '.update_height' do
          it "sets node height to higher value of descendants' height" do
            node = AvlTree::Node.instance(5, 'foo').tap { |node| node.height = 2 }
            node.left = AvlTree::Node.instance(4, 'bar').tap { |left| left.height = 1 }
            node.right = AvlTree::Node.instance(6, 'bax').tap { |right| right.height = 3 }
            expect do
              BalanceImpl.update_height(node)
            end.to change(node, :height).from(2).to(4)
          end
        end

        describe '.height' do
          context 'when node is present' do
            it 'returns node height' do
              node = AvlTree::Node.instance(5, 'string').tap { |node| node.height = 2 }
              expect(BalanceImpl.height(node)).to eq(2)
            end
          end

          context 'when node is nil' do
            it 'returns 0' do
              expect(BalanceImpl.height(nil)).to eq(0)
            end
          end
        end
      end
    end
  end
end
