# frozen_string_literal: true

module Lite
  module Containers
    class AvlTree
      module Traversal
        def traverse(node, yielder, from:, to:)
          return unless node

          after_start = after_back_guard?(node, from)
          traverse(node.left, yielder, from: from, to: to) if after_start
          return unless before_front_guard?(node, to)

          yielder.yield node.out if after_start
          traverse(node.right, yielder, from: from, to: to)
        end

        def reverse_traverse(node, yielder, from:, to:)
          return unless node

          after_start = before_front_guard?(node, from)
          reverse_traverse(node.right, yielder, from: from, to: to) if after_start
          return unless after_back_guard?(node, to)

          yielder.yield node.out if after_start
          reverse_traverse(node.left, yielder, from: from, to: to)
        end

        def after_back_guard?(node, guard)
          return true if guard.nil?

          compare(guard, node.key) < 1
        end

        def before_front_guard?(node, guard)
          return true if guard.nil?

          compare(node.key, guard) < 1
        end
      end
    end
  end
end
