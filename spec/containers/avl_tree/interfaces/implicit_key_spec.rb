# frozen_string_literal: true

require_relative '../../../../lib/lite/containers/avl_tree'

module Lite
  module Containers
    class AvlTree
      RSpec.describe ImplicitKey do
        let(:key_extractor) do
          table = {
            one: 1,
            two: 2,
            three: 3,
            four: 4,
            five: 5
          }
          proc { table.fetch(_1) }
        end

        let(:tree_queue) { described_class.instance(:max, key_extractor: key_extractor) }

        describe 'push' do
          it 'inserts key/value pair' do
            tree_queue.push :two
            expect(tree_queue[2]).to eq(:two)
          end
        end

        describe '<<' do
          it 'inserts key/value pair and returns queue object' do
            tree_queue << :three << :one << :four
            expect(tree_queue.traverse.to_a).to eq(%i[one three four])
          end
        end
      end
    end
  end
end
