# frozen_string_literal: true

module Lite
  module Containers
    module Abstract
      module Queue
        # Returns highest priority element or nil if empty
        def front
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Removes and returns highest priority element or nil if empty
        def pop_front
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Returns all elements in descending order by priority
        def drain!
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end
      end
    end
  end
end
