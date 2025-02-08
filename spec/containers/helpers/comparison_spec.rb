# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/helpers/comparison'

module Lite
  module Containers
    module Helpers
      RSpec.describe Comparison do
        context 'max type without key extractor' do
          let(:comparison) { described_class.instance :max }

          describe '#to_key' do
            it 'returns the element' do
              expect(comparison.to_key(5)).to eq(5)
            end
          end

          describe '#for_key' do
            it 'returns comparator for given key/element' do
              comparator = comparison.for_key(5)
              expect(comparator.call(10)).to eq(-1)
              expect(comparator.call(5)).to eq(0)
              expect(comparator.call(0)).to eq(1)
            end
          end

          describe '#compare' do
            it 'behaves as <=>' do
              expect(comparison.compare(1, 2)).to eq(-1)
              expect(comparison.compare(1, 1)).to eq(0)
              expect(comparison.compare(2, 1)).to eq(1)
            end
          end

          describe '#invert' do
            it 'returns min type comparison' do
              expect(comparison.invert.compare(1, 2)).to eq(1)
            end
          end
        end

        context 'min type without key extractor' do
          let(:comparison) { described_class.instance :min }

          describe '#compare' do
            it 'behaves as inverted <=>' do
              expect(comparison.compare(1, 3)).to eq(1)
              expect(comparison.compare(1, 1)).to eq(0)
              expect(comparison.compare(3, 1)).to eq(-1)
            end
          end

          describe '#invert' do
            it 'returns max type comparison' do
              expect(comparison.invert.compare(1, 3)).to eq(-1)
            end
          end
        end

        context 'max type with key extractor' do
          let(:comparison) { described_class.instance :max, key_extractor: -> { _1[:index] } }

          describe '#to_key' do
            it 'extracts the key' do
              expect(comparison.to_key({ index: 5 })).to eq(5)
            end
          end

          describe '#compare' do
            it 'extracts keys and compares them using <=>' do
              expect(comparison.compare({ index: 1 }, { index: 2 })).to eq(-1)
              expect(comparison.compare({ index: 1 }, { index: 1 })).to eq(0)
              expect(comparison.compare({ index: 2 }, { index: 1 })).to eq(1)
            end
          end

          describe '#invert' do
            it 'returns min type comparison with key extractor' do
              expect(comparison.invert.compare({ index: 1 }, { index: 2 })).to eq(1)
            end
          end
        end

        context 'min type with key extractor' do
          let(:comparison) { described_class.instance :min, key_extractor: -> { _1[:index] } }

          describe '#for_item' do
            it 'returns comparator for given element' do
              comparator = comparison.for_item({ index: 5 })
              expect(comparator.call({ index: 10 })).to eq(1)
              expect(comparator.call({ index: 5 })).to eq(0)
              expect(comparator.call({ index: 0 })).to eq(-1)
            end
          end

          describe '#for_key' do
            it 'returns comparator for given key' do
              comparator = comparison.for_key(5)
              expect(comparator.call({ index: 10 })).to eq(1)
              expect(comparator.call({ index: 5 })).to eq(0)
              expect(comparator.call({ index: 0 })).to eq(-1)
            end
          end

          describe '#compare' do
            it 'extracts keys and compares them using inverted <=>' do
              expect(comparison.compare({ index: 1 }, { index: 3 })).to eq(1)
              expect(comparison.compare({ index: 1 }, { index: 1 })).to eq(0)
              expect(comparison.compare({ index: 3 }, { index: 1 })).to eq(-1)
            end
          end

          describe '#invert' do
            it 'returns max type comparison with key extractor' do
              expect(comparison.invert.compare({ index: 1 }, { index: 2 })).to eq(-1)
            end
          end
        end
      end
    end
  end
end
