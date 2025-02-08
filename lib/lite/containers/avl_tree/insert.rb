# frozen_string_literal: true

require_relative 'node'

module Lite
  module Containers
    class AvlTree
      module Insert
        def insert(node, key, value, merge, factory)
          return true, factory.instance(key, value) if node.nil?

          case compare(key, node.key)
          when -1
            increment, node.left = insert(node.left, key, value, merge, factory)
            [increment, rebalance(node)]
          when 0
            node.value = merge.merge(node.value, value)
            [false, node]
          when 1
            increment, node.right = insert(node.right, key, value, merge, factory)
            [increment, rebalance(node)]
          end
        end
      end
    end
  end
end
