# frozen_string_literal: true

require_relative 'abstract'
require_relative 'deque'
require_relative '../avl_tree'

module Lite
  module Containers
    module TopN
      class AvlTree
        include Deque
        include Abstract

        Backend = Containers::AvlTree::ImplicitKey

        def self.instance(type, limit: nil, filter: nil, **backend_options)
          backend = Backend.instance(type, **backend_options)
          new backend, limit, filter
        end
      end

      register_backend :avl_tree, AvlTree
    end
  end
end
