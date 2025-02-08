# frozen_string_literal: true

require_relative '../../support/avl_tree/helper'
require_relative '../../support/avl_tree/test_tree'

module Lite
  module Containers
    class AvlTree
      module DeleteImpl
        extend Balance
        extend Delete
        extend Find

        def self.compare(a, b)
          Helpers::Comparison::Max.compare(a, b)
        end
      end

      describe Delete do
        context 'when deleting node with no children set' do
          let(:node) do
            Node.instance(20, :root).tap do |node|
              node.height = 2
              node.left = Node.instance(10, :left).tap { |node| node.height = 1 }
            end
          end

          it 'updates height' do
            _, new_root = DeleteImpl.delete(10, node)
            expect(new_root).to have_attributes(key: 20, height: 1)
          end
        end

        context 'when deleting node with left side set' do
          let(:node) do
            Node.instance(20, :root).tap do |node|
              node.height = 3
              node.left = Node.instance(10, :left).tap do |node|
                node.height = 2
                node.left = Node.instance(5, :left_left).tap { |node| node.height = 1 }
              end
            end
          end

          it 'reassigns the left side' do
            _, new_root = DeleteImpl.delete(10, node)
            expected = {
              k: 20, h: 2, l: { k: 5, h: 1 }
            }
            expect(new_root).to have_structure(expected)
          end

          context 'when unbalancing right right side' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 4
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 2
                  node.left = Node.instance(5, :left_left).tap { |node| node.height = 1 }
                end
                node.right = Node.instance(30, :right).tap do |node|
                  node.height = 3
                  node.left = Node.instance(25, :right_left).tap { |node| node.height = 1 }
                  node.right = Node.instance(40, :right_right).tap do |node|
                    node.height = 2
                    node.right = Node.instance(45, :right_right_right).tap { |node| node.height = 1 }
                  end
                end
              end
            end

            it 'rebalances' do
              _, new_root = DeleteImpl.delete(10, node)
              expected = {
                k: 30, h: 3, l: { k: 20, h: 2, l: { k: 5, h: 1 }, r: { k: 25, h: 1 } },
                r: { k: 40, h: 2, r: { k: 45, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end

          context 'when unbalancing right left side' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 4
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 2
                  node.left = Node.instance(5, :left_left).tap { |node| node.height = 1 }
                end
                node.right = Node.instance(30, :right).tap do |node|
                  node.height = 3
                  node.left = Node.instance(25, :right_left).tap { |node| node.height = 1 }
                  node.right = Node.instance(40, :right_right).tap do |node|
                    node.height = 2
                    node.left = Node.instance(35, :right_right_left).tap { |node| node.height = 1 }
                  end
                end
              end
            end

            it 'rebalances' do
              _, new_root = DeleteImpl.delete(10, node)
              expected = {
                k: 30, h: 3, l: { k: 20, h: 2, l: { k: 5, h: 1 }, r: { k: 25, h: 1 } },
                r: { k: 40, h: 2, l: { k: 35, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        context 'when deleting node with right side set' do
          let(:node) do
            Node.instance(5, :root).tap do |node|
              node.height = 3
              node.right = Node.instance(10, :left).tap do |node|
                node.height = 2
                node.right = Node.instance(20, :left_left).tap { |node| node.height = 1 }
              end
            end
          end

          it 'reassigns the right side' do
            _, new_root = DeleteImpl.delete(10, node)
            expected = {
              k: 5, h: 2, r: { k: 20, h: 1 }
            }
            expect(new_root).to have_structure(expected)
          end

          context 'when unbalancing left left side' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 4
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 3
                  node.left = Node.instance(5, :left_left).tap do |node|
                    node.height = 2
                    node.left = Node.instance(0, :left_left_left).tap { |node| node.height = 1 }
                  end
                  node.right = Node.instance(15, :left_right).tap { |node| node.height = 1 }
                end
                node.right = Node.instance(25, :right).tap do |node|
                  node.height = 2
                  node.right = Node.instance(30, :right_right).tap { |node| node.height = 1 }
                end
              end
            end

            it 'rebalances' do
              _, new_root = DeleteImpl.delete(25, node)
              expected = {
                k: 10, h: 3, l: { k: 5, h: 2, l: { k: 0, h: 1 } },
                r: { k: 20, h: 2, l: { k: 15, h: 1 }, r: { k: 30, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end

          context 'when unbalancing left right side' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 4
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 3
                  node.left = Node.instance(5, :left_left).tap do |node|
                    node.height = 2
                    node.right = Node.instance(7, :left_left_right).tap { |node| node.height = 1 }
                  end
                  node.right = Node.instance(15, :left_right).tap { |node| node.height = 1 }
                end
                node.right = Node.instance(25, :right).tap do |node|
                  node.height = 2
                  node.right = Node.instance(30, :right_right).tap { |node| node.height = 1 }
                end
              end
            end

            it 'rebalances' do
              _, new_root = DeleteImpl.delete(25, node)
              expected = {
                k: 10, h: 3, l: { k: 5, h: 2, r: { k: 7, h: 1 } },
                r: { k: 20, h: 2, l: { k: 15, h: 1 }, r: { k: 30, h: 1 } }
              }
              expect(new_root).to have_structure(expected)
            end
          end
        end

        context 'when deleting node with both sides set' do
          let(:node) do
            Node.instance(20, :root).tap do |node|
              node.height = 4
              node.left = Node.instance(10, :left).tap do |node|
                node.height = 3
                node.left = Node.instance(5, :left_left).tap do |node|
                  node.height = 2
                  node.right = Node.instance(7, :left_left_right).tap { |node| node.height = 1 }
                end
                node.right = Node.instance(15, :left_right).tap do |node|
                  node.height = 2
                  node.left = Node.instance(12, :left_right_left).tap { |node| node.height = 1 }
                end
              end
              node.right = Node.instance(25, :right).tap do |node|
                node.height = 2
                node.right = Node.instance(30, :right_right).tap { |node| node.height = 1 }
              end
            end
          end

          it 'updates structure correctly' do
            _, new_root = DeleteImpl.delete(10, node)
            expected = {
              k: 20, h: 4, l: { k: 12, h: 3, l: { k: 5, h: 2, r: { k: 7, h: 1 } }, r: { k: 15, h: 1 } },
              r: { k: 25, h: 2, r: { k: 30, h: 1 } }
            }
            expect(TestTree.consistent?(new_root, :max)).to eq([true, 4, 7])
            expect(new_root).to have_structure(expected)
          end

          context 'when unbalancing tree' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 5
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 4
                  node.left = Node.instance(5, :left_left).tap do |node|
                    node.height = 3
                    node.left = Node.instance(3, :left_left_left).tap do |node|
                      node.height = 2
                      node.left = Node.instance(1, :left_left_left_left).tap { |node| node.height = 1 }
                    end
                    node.right = Node.instance(7, :left_left_right).tap { |node| node.height = 1 }
                  end
                  node.right = Node.instance(15, :left_right).tap do |node|
                    node.height = 2
                    node.left = Node.instance(12, :left_right_left).tap { |node| node.height = 1 }
                  end
                end
                node.right = Node.instance(25, :right).tap do |node|
                  node.height = 3
                  node.left = Node.instance(22, :right_right).tap { |node| node.height = 1 }
                  node.right = Node.instance(30, :right_right).tap do |node|
                    node.height = 2
                    node.left = Node.instance(27, :right_right).tap { |node| node.height = 1 }
                  end
                end
              end
            end

            it 'rebalances' do
              _, new_root = DeleteImpl.delete(10, node)
              expected = {
                k: 20, h: 4, l: { k: 5, h: 3, l: { k: 3, h: 2, l: { k: 1, h: 1 } },
                                  r: { k: 12, h: 2, l: { k: 7, h: 1 }, r: { k: 15, h: 1 } } },
                r: { k: 25, h: 3, l: { k: 22, h: 1 },
                     r: { k: 30, h: 2, l: { k: 27, h: 1 } } }
              }
              expect(TestTree.consistent?(new_root, :max)).to eq([true, 4, 11])
              expect(new_root).to have_structure(expected)
            end
          end

          context 'when leftmost child of deleted node has right side' do
            let(:node) do
              Node.instance(20, :root).tap do |node|
                node.height = 5
                node.left = Node.instance(10, :left).tap do |node|
                  node.height = 4
                  node.left = Node.instance(5, :left_left).tap do |node|
                    node.height = 2
                    node.right = Node.instance(7, :left_left_right).tap { |node| node.height = 1 }
                  end
                  node.right = Node.instance(15, :left_right).tap do |node|
                    node.height = 3
                    node.left = Node.instance(12, :left_right_left).tap do |node|
                      node.height = 2
                      node.right = Node.instance(14, :left_right_left_right).tap { |node| node.height = 1 }
                    end
                    node.right = Node.instance(17, :left_right_right).tap { |node| node.height = 1 }
                  end
                end
                node.right = Node.instance(25, :right).tap do |node|
                  node.height = 3
                  node.left = Node.instance(22, :right_right).tap { |node| node.height = 1 }
                  node.right = Node.instance(30, :right_right).tap do |node|
                    node.height = 2
                    node.left = Node.instance(27, :right_right).tap { |node| node.height = 1 }
                  end
                end
              end
            end

            it 'keeps all non-deleted nodes' do
              _, new_root = DeleteImpl.delete(10, node)
              expected = {
                k: 20, h: 4, l: { k: 12, h: 3, l: { k: 5, h: 2, r: { k: 7, h: 1 } },
                                  r: { k: 15, h: 2, l: { k: 14, h: 1 }, r: { k: 17, h: 1 } } },
                r: { k: 25, h: 3, l: { k: 22, h: 1 },
                     r: { k: 30, h: 2, l: { k: 27, h: 1 } } }
              }
              expect(TestTree.consistent?(new_root, :max)).to eq([true, 4, 11])
              expect(new_root).to have_structure(expected)
            end
          end
        end
      end
    end
  end
end
