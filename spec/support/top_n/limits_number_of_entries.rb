# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/top_n'

module Lite
  module Containers
    RSpec.shared_examples 'limits number of entries' do
      let(:queue) do
        TopN.instance(
          backend,
          :max,
          limit: 2
        )
      end

      before do
        [5, 1].each do |item|
          queue.push(item)
        end
      end

      describe '#push' do
        context 'on collision' do
          it 'merges colliding elements' do
            queue.push(9)
            queue.push(7)
            result = queue.drain!
            expect(result).to eq([9, 7])
          end
        end
      end
    end
  end
end
