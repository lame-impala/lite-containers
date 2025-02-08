# frozen_string_literal: true

module Lite
  module Containers
    module Abstract
      module Collection
        def size
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        def length
          size
        end

        def count
          size
        end

        def empty?
          size.zero?
        end
      end
    end
  end
end
