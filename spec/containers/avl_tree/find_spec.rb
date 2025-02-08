# frozen_string_literal: true

require_relative '../../support/avl_tree/helper'
require_relative '../../../lib/lite/containers/avl_tree/find'

module Lite
  module Containers
    class AvlTree
      module FindImpl
        extend Find
      end

      RSpec.describe Find do
        context 'with balanced node' do
          include_context 'balanced node'

          describe '::leftmost_child' do
            it 'returns the correct node' do
              expect(FindImpl.leftmost_child(balanced).key).to eq(4)
            end
          end

          describe '::rightmost_child' do
            it 'returns the correct node' do
              expect(FindImpl.rightmost_child(balanced).key).to eq(32)
            end
          end
        end
      end
    end
  end
end
