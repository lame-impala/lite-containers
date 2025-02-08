# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/top_n'

module Lite
  module Containers
    RSpec.shared_examples 'uses key extractor' do
      let(:queue) do
        TopN.instance(
          backend,
          :max,
          key_extractor: proc(&:-@)
        )
      end

      describe '#push' do
        it 'extracts key from value' do
          queue.push(5)
          queue.push(1)
          queue.push(3)

          result = queue.drain!
          expect(result).to eq([1, 3, 5])
        end
      end
    end
  end
end
