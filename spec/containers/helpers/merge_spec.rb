# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/helpers/merge'

module Lite
  module Containers
    module Helpers
      RSpec.describe Merge do
        context 'with `replace` strategy' do
          let(:merge) { described_class.instance(:replace) }

          describe '#merge' do
            it 'returns the fresh element' do
              expect(merge.merge({ index: 5, id: :old }, { index: 5, id: :fresh })).to eq({ index: 5, id: :fresh })
            end
          end
        end

        context 'with `keep` strategy' do
          let(:merge) { described_class.instance(:keep) }

          describe '#merge' do
            it 'returns the old element' do
              expect(merge.merge({ index: 5, id: :old }, { index: 5, id: :fresh })).to eq({ index: 5, id: :old })
            end
          end
        end

        context 'with custom strategy' do
          let(:merge) { described_class.instance(->(a, _b) { a.merge(count: (a[:count] || 1) + 1) }) }

          describe '#merge' do
            it 'applies custom strategy' do
              expect(merge.merge({ index: 5 }, { index: 5 }))
                .to eq({ index: 5, count: 2 })
            end
          end
        end
      end
    end
  end
end
