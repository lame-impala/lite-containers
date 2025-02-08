# frozen_string_literal: true

require 'forwardable'
require_relative 'error'
require_relative '../abstract/collection'
require_relative '../abstract/implicit_key'
require_relative '../top_n'

module Lite
  module Containers
    module TopN
      module Abstract
        include Containers::Abstract::Collection
        include Containers::Abstract::ImplicitKey
        extend Forwardable

        def_delegator(:@backend, :size)

        def initialize(backend, limit, filter)
          @backend = backend
          @limit = limit
          @filter = filter
        end

        attr_reader :limit

        def push(new_item)
          return unless pass?(new_item)

          @backend.push(new_item)
          shrink
        end

        def drain!
          @backend.drain!
        end

        private

        def pass?(item)
          return true if @filter.nil?

          @filter.call(item)
        end

        def shrink
          return [] if @limit.nil?

          drop = []
          drop << pop while @backend.size > @limit
          drop
        end
      end
    end
  end
end
