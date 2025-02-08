# frozen_string_literal: true

require_relative 'queue'

module Lite
  module Containers
    module Abstract
      module Deque
        include Queue

        # Removes and returns lowest priority element. Does nothing if empty
        def back
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Removes and returns lowest priority element. Does nothing if empty
        def pop_back
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end
      end
    end
  end
end
