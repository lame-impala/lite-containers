# frozen_string_literal: true

require_relative '../error'

module Lite
  module Containers
    module Helpers
      module Merge
        class Error < Containers::Error; end

        def self.instance(strategy)
          case strategy
          when nil, :replace then Replace
          when :keep then Keep
          when Proc then Custom.new(strategy)
          else raise Error, "Unexpected strategy for merge: #{strategy}"
          end
        end

        class Replace
          def self.merge(_old, fresh)
            fresh
          end
        end

        class Keep
          def self.merge(old, _fresh)
            old
          end
        end

        class Custom
          def initialize(proc)
            @proc = proc
            freeze
          end

          def merge(old, fresh)
            proc.call(old, fresh)
          end

          private

          attr_reader :proc
        end
      end
    end
  end
end
