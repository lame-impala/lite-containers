# frozen_string_literal: true

require_relative 'abstract'
require_relative '../../node'

module Lite
  module Containers
    class AvlTree
      module Interfaces
        module KeyExtractionStrategy
          module Explicit
            class Node < AvlTree::Node
              def out
                [key, value]
              end
            end

            include Abstract

            def insert(key, value)
              insert_pair(key, value)
            end

            private

            def node_factory
              Node
            end
          end
        end
      end
    end
  end
end
