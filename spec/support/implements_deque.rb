# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements deque' do
      describe '#back' do
        it 'returns lowest priority element' do
          min_deque << 5 << 1 << 3
          front = min_deque.back
          expect(front).to eq(5)
        end

        context 'when empty' do
          it 'returns nil' do
            expect(min_deque.back).to be_nil
          end
        end
      end

      describe '#pop_back' do
        it 'returns lowest priority element' do
          min_deque << 5 << 1 << 3
          front = min_deque.pop_back
          expect(front).to eq(5)
        end

        it 'removes least priority element' do
          min_deque << 5 << 1 << 3
          min_deque.pop_back
          result = min_deque.drain!
          expect(result).to eq([1, 3])
        end

        context 'when empty' do
          it 'returns nil' do
            expect(min_deque.pop_back).to be_nil
          end

          it 'leaves the queue empty' do
            min_deque.pop_back
            expect(min_deque).to be_empty
          end
        end
      end
    end
  end
end
