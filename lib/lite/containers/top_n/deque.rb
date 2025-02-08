# frozen_string_literal: true

require_relative '../abstract/deque'

module Lite
  module Containers
    module TopN
      module Deque
        include Containers::Abstract::Deque

        def pop
          pop_back
        end

        def front
          @backend.front
        end

        def pop_front
          @backend.pop_front
        end

        def back
          @backend.back
        end

        def pop_back
          @backend.pop_back
        end
      end
    end
  end
end
