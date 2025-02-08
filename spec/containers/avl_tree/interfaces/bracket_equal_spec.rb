# frozen_string_literal: true

require_relative '../../../../lib/lite/containers/avl_tree'
require_relative '../../../../lib/lite/containers/avl_tree/interfaces/bracket_assign'

module Lite
  module Containers
    class AvlTree
      class TreeMap < AvlTree
        include Interfaces::BracketAssign
      end

      RSpec.describe Interfaces::BracketAssign do
        let(:tree_map) { TreeMap.instance(:max) }

        context 'when merge strategy is passed in as argument' do
          it 'raises error' do
            expect { TreeMap.instance(:max, merge: :keep) }
              .to raise_error(ArgumentError, 'Disallowed keyword argument: merge')
          end
        end

        describe '[]=' do
          it 'inserts key/value pair' do
            tree_map[2] = :two
            expect(tree_map[2]).to eq(:two)
          end

          context 'on collision' do
            it 'uses `replace` merge strategy' do
              tree_map[2] = :two
              tree_map[2] = :TWO
              expect(tree_map[2]).to eq(:TWO)
            end
          end
        end
      end
    end
  end
end
