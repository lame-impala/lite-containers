# frozen_string_literal: true

require_relative '../error'
require_relative '../helpers/comparison'
require_relative 'insert'
require_relative 'delete'
require_relative 'balance'
require_relative 'traversal'
require_relative 'find'

module Lite
  module Containers
    class AvlTree
      class Error < Containers::Error; end

      module Implementation
        def self.instance(type)
          type = type.to_sym
          case type
          when :max then Max
          when :min then Min
          else raise Error, Error, "Unexpected AVL tree type: '#{type}'"
          end
        end

        include Balance
        include Delete
        include Insert
        include Find
        include Traversal

        module Max
          extend Implementation

          module Compare
            def compare(a, b)
              Helpers::Comparison::Max.compare(a, b)
            end
          end

          module Exact
            extend Find::Exact
            extend Compare
          end

          module ExactOrNearestForwards
            extend Find::ExactOrNearestForwards
            extend Compare
          end

          module ExactOrNearestBackwards
            extend Find::ExactOrNearestBackwards
            extend Compare
          end

          extend Compare
        end

        module Min
          extend Implementation

          module Compare
            def compare(a, b)
              Helpers::Comparison::Min.compare(a, b)
            end
          end

          module Exact
            extend Find::Exact
            extend Compare
          end

          module ExactOrNearestForwards
            extend Find::ExactOrNearestForwards
            extend Compare
          end

          module ExactOrNearestBackwards
            extend Find::ExactOrNearestBackwards
            extend Compare
          end

          extend Compare
        end
      end
    end
  end
end
