# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/top_n'

module Lite
  module Containers
    RSpec.shared_examples 'has deque properties' do
      let(:queue) { TopN.instance(backend, :max) }

      context 'with empty queue' do
        describe '#pop_back' do
          it 'returns nil' do
            expect(queue.pop_back).to be_nil
          end
        end

        describe '#pop_front' do
          it 'returns nil' do
            expect(queue.pop_front).to be_nil
          end
        end
      end

      context 'with non-empty queue' do
        before do
          [5, 1, 3].each do |item|
            queue.push(item)
          end
        end

        describe '#pop_back' do
          it 'returns minimum' do
            value = queue.pop_back
            expect(value).to eq(1)
          end
        end

        describe '#pop_front' do
          it 'returns maximum' do
            value = queue.pop_front
            expect(value).to eq(5)
          end
        end
      end
    end
  end
end
