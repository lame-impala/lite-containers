# frozen_string_literal: true

require_relative 'key_extraction_strategy/explicit'
require_relative '../../helpers/merge'

module Lite
  module Containers
    class AvlTree
      module Interfaces
        module BracketAssign
          include KeyExtractionStrategy::Explicit

          module Instance
            def instance(type, **opts)
              raise ArgumentError, 'Disallowed keyword argument: merge' if opts.key?(:merge)

              super(type, merge: :replace, **opts)
            end
          end

          def self.included(base)
            KeyExtractionStrategy::Abstract.enforce_exclusion!(base, KeyExtractionStrategy::Explicit)
            base.extend Instance
          end

          def []=(key, value)
            insert_pair key, value
          end
        end
      end
    end
  end
end
