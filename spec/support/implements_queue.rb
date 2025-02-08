# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements queue' do
      describe '#front' do
        it 'returns highest priority element' do
          min_queue << 5 << 1 << 3
          front = min_queue.front
          expect(front).to eq(1)
        end

        context 'when empty' do
          it 'returns nil' do
            expect(min_queue.front).to be_nil
          end
        end
      end

      describe '#pop_front' do
        it 'returns highest priority element' do
          min_queue << 5 << 1 << 3
          front = min_queue.pop_front
          expect(front).to eq(1)
        end

        it 'removes highest priority element' do
          min_queue << 5 << 1 << 3
          min_queue.pop_front
          result = min_queue.drain!
          expect(result).to eq([3, 5])
        end

        context 'when empty' do
          it 'returns nil' do
            expect(min_queue.pop_front).to be_nil
          end

          it 'leaves the queue empty' do
            min_queue.pop_front
            expect(min_queue).to be_empty
          end
        end
      end

      describe '#drain!' do
        it 'returns array of elements in descending order by priority' do
          min_queue << 5 << 1 << 3
          result = min_queue.drain!
          expect(result).to eq([1, 3, 5])
        end

        it 'empties the queue' do
          min_queue << 5 << 1 << 3
          min_queue.drain!
          expect(min_queue).to be_empty
        end
      end
    end
  end
end
