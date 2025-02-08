# frozen_string_literal: true

require_relative 'queue'

module Lite
  module Containers
    module Abstract
      module ImplicitKey
        # Inserts element at its corresponding place.
        # In case element is already there applies merge strategy
        def push(_element)
          raise NotImplementedError, "#{self.class.name}##{__method__} unimplemented"
        end

        # Inserts element the way push does. Returns self
        def <<(element)
          push(element)
          self
        end
      end
    end
  end
end
