# frozen_string_literal: true

module Lite
  module Containers
    module Abstract
      module SortedMap
        # Returns if key exists, false otherwise
        def key?(key)
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Returns element under given key if exists
        def find(_key)
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Returns element under given key or nearest element under lower priority key if exists
        def find_or_nearest_backwards(_key)
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Returns value under given key or nearest element under higher priority key if exists
        def find_or_nearest_forwards(_key)
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end
      end
    end
  end
end
