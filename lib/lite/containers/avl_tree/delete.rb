# frozen_string_literal: true

module Lite
  module Containers
    class AvlTree
      module Delete
        def delete(key, node) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          return [nil, nil] if node.nil?

          case compare(key, node.key)
          when -1
            deleted, node.left = delete(key, node.left)
            [deleted, rebalance(node)]
          when 0
            if node.left.nil? || node.right.nil?
              new_root = node.left.nil? ? node.right : node.left
              [node, new_root]
            else
              new_root = leftmost_child(node.right)
              _, new_root.right = delete(new_root.key, node.right)
              new_root.left = node.left
              [node, rebalance(new_root)]
            end
          when 1
            deleted, node.right = delete(key, node.right)
            [deleted, rebalance(node)]
          end
        end
      end
    end
  end
end
