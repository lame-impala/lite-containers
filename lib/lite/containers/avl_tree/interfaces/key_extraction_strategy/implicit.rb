# frozen_string_literal: true

require_relative '../../../helpers/key_extractor'
require_relative '../../../abstract/implicit_key'
require_relative '../../node'
require_relative 'abstract'

module Lite
  module Containers
    class AvlTree
      module Interfaces
        module KeyExtractionStrategy
          module Implicit
            include Abstract
            include Containers::Abstract::ImplicitKey

            class Node < AvlTree::Node
              def out
                value
              end
            end

            module Instance
              def instance(type, key_extractor: nil, **opts)
                super(type, key_extractor: Helpers::KeyExtractor.instance(key_extractor), **opts)
              end
            end

            def self.included(base)
              Abstract.enforce_exclusion!(base, self)
              base.extend Instance
            end

            def initialize(*args, key_extractor:, **opts)
              @key_extractor = key_extractor
              super(*args, **opts)
            end

            def push(value)
              key = extract_key(value)
              insert_pair key, value
            end

            private

            def extract_key(object)
              return object if @key_extractor.nil?

              @key_extractor.to_key(object)
            end

            def node_factory
              Node
            end
          end
        end
      end
    end
  end
end
