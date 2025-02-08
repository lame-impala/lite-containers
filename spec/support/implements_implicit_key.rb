# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements implicit key' do
      describe '#<<' do
        it 'inserts element at its correct place and returns self' do
          max_queue << 5 << 1 << 3
          result = max_queue.drain!
          expect(result).to eq([5, 3, 1])
        end
      end
    end
  end
end
