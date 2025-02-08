# frozen_string_literal: true

require_relative '../../../error'

module Lite
  module Containers
    class AvlTree
      module Interfaces
        module KeyExtractionStrategy
          module Abstract
            def self.included(base)
              register(base)
              enforce_exclusion(base, base)
            end

            def self.register(strategy)
              registry << strategy
            end

            def self.registry
              @registry ||= Set.new
            end

            def self.enforce_exclusion(mod, strategy)
              mod.define_singleton_method :included do |base|
                Abstract.enforce_exclusion!(base, strategy)
                super(base)
              end
            end

            def self.enforce_exclusion!(base, strategy)
              conflicts = Abstract
                          .registry
                          .select { |candidate| strategy != candidate && base < candidate }
                          .map { |conflict| conflict.name.split('::').last }

              if !conflicts.empty?
                raise Error, "Key extraction strategy conflict: #{conflicts.join(', ')}"
              elsif base.is_a?(Module)
                Abstract.enforce_exclusion(base, strategy)
              end
            end
          end
        end
      end
    end
  end
end
