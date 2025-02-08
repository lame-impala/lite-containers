# frozen_string_literal: true

require_relative 'abstract'
require_relative '../heap'

module Lite
  module Containers
    module TopN
      class Heap
        include Abstract

        Backend = Containers::Heap

        def self.instance(type, limit: nil, filter: nil, key_extractor: nil)
          comparison = Helpers::Comparison.instance(type, key_extractor: key_extractor).invert
          backend = Backend.with_comparison(comparison)
          new backend, limit, filter
        end

        def pop
          @backend.pop
        end

        def drain!
          @backend.drain!.reverse
        end
      end

      register_backend :heap, Heap
    end
  end
end
