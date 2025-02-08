# frozen_string_literal: true

require_relative '../helpers/comparison'

module Lite
  module Containers
    class AvlTree
      module Find
        def leftmost_child(node)
          return node if node.left.nil?

          leftmost_child(node.left)
        end

        def rightmost_child(node)
          return node if node.right.nil?

          rightmost_child(node.right)
        end

        module Exact
          def find(key, node)
            return nil unless node

            case compare(key, node.key)
            when -1
              find(key, node.left)
            when 0
              node
            when 1
              find(key, node.right)
            end
          end
        end

        module Inexact
          def find(key, node)
            exact, candidate = find_candidate(key, node)
            exact || candidate
          end

          def find_candidate(key, node)
            return [nil, nil] unless node

            case lookup_direction(key, node.key)
            when -1
              find_candidate(key, lookup_path(node, -1))
            when 0
              [node, nil]
            when 1
              exact, candidate = find_candidate(key, lookup_path(node, 1))
              if exact
                [exact, nil]
              elsif candidate
                [nil, candidate]
              else
                [nil, node]
              end
            end
          end
        end

        module ExactOrNearestBackwards
          include Inexact

          def lookup_direction(search_key, node_key)
            compare(search_key, node_key)
          end

          def lookup_path(node, comparison_result)
            case comparison_result
            when -1 then node.left
            when 1 then node.right
            else
              raise Helpers::Comparison::Error, "Unexpected comparison result: #{comparison_result}"
            end
          end
        end

        module ExactOrNearestForwards
          include Inexact

          def lookup_direction(search_key, node_key)
            compare(node_key, search_key)
          end

          def lookup_path(node, comparison_result)
            case comparison_result
            when -1 then node.right
            when 1 then node.left
            else
              raise Helpers::Comparison::Error, "Unexpected comparison result: #{comparison_result}"
            end
          end
        end
      end
    end
  end
end
