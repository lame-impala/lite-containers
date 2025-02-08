# frozen_string_literal: true

module Lite
  module Containers
    class AvlTree
      module Balance
        def rebalance(node) # rubocop:disable Metrics/AbcSize
          case balance_factor(node)
          when -2
            if height(node.left.right) > height(node.left.left)
              rotate_left_right(node)
            else
              rotate_right(node)
            end
          when 2
            if height(node.right.left) > height(node.right.right)
              rotate_right_left(node)
            else
              rotate_left(node)
            end
          else
            update_height(node)
            node
          end
        end

        def rotate_left(node)
          right = node.right
          node.right = right.left
          right.left = node
          update_height node
          update_height right
          right
        end

        def rotate_right(node)
          left = node.left
          node.left = left.right
          left.right = node
          update_height node
          update_height left
          left
        end

        def rotate_right_left(node)
          node.right = rotate_right(node.right)
          rotate_left(node)
        end

        def rotate_left_right(node)
          node.left = rotate_left(node.left)
          rotate_right(node)
        end

        def update_height(node)
          left_height = height(node.left)
          right_height = height(node.right)
          # rubocop:disable Style/MinMaxComparison
          max = left_height > right_height ? left_height : right_height
          # rubocop:enable Style/MinMaxComparison
          node.height = max + 1
        end

        def balance_factor(node)
          height(node.right) - height(node.left)
        end

        def height(node)
          node&.height || 0
        end
      end
    end
  end
end
