# frozen_string_literal: true

require_relative '../error'

module Lite
  module Containers
    module Helpers
      module Comparison
        class Error < Containers::Error; end

        def self.instance(type, key_extractor: nil)
          type = type.to_sym
          case type
          when :max then Max.instance(key_extractor)
          when :min then Min.instance(key_extractor)
          else raise Error, "Unexpected comparison type: '#{type}'"
          end
        end

        class Abstract
          def initialize(key_extractor)
            @key_extractor = key_extractor
            freeze
          end

          def to_key(element)
            @key_extractor.call(element)
          end

          def for_item(item)
            method(:compare).curry.call(item)
          end

          def for_key(key)
            comparison = self.class
            proc do |b|
              comparison.compare(key, to_key(b))
            end
          end

          def compare(a, b)
            self.class.compare(to_key(a), to_key(b))
          end

          class << self
            def to_key(element)
              element
            end

            def for_item(item)
              method(:compare).curry.call(item)
            end

            alias for_key for_item
          end
        end

        class Max < Abstract
          def invert
            Comparison.instance :min, key_extractor: @key_extractor
          end

          class << self
            def instance(key_extractor)
              key_extractor ? new(key_extractor) : self
            end

            def compare(a, b)
              result = a <=> b
              raise Error, "No meaningful comparison between #{a} <=> #{b}" if result.nil?

              result
            end

            def invert
              Min
            end
          end
        end

        class Min < Abstract
          def invert
            Comparison.instance :max, key_extractor: @key_extractor
          end

          class << self
            def instance(key_extractor)
              key_extractor ? new(key_extractor) : self
            end

            def compare(a, b)
              result = b <=> a
              raise Error, "No meaningful comparison between #{a} <=> #{b}" if result.nil?

              result
            end

            def invert
              Max
            end
          end
        end
      end
    end
  end
end
