# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/sorted_array/binary_search'

module Lite
  module Containers
    class SortedArray
      RSpec.describe BinarySearch do
        describe '#midpoint' do
          context 'upper - lower = 0' do
            it 'returns lower' do
              expect(described_class.midpoint(5, 5)).to eq(5)
            end
          end

          context 'upper - lower = 1' do
            it 'returns lower' do
              expect(described_class.midpoint(5, 6)).to eq(5)
            end
          end

          context 'upper - lower > 1' do
            it 'returns midpoint' do
              expect(described_class.midpoint(5, 7)).to eq(6)
            end
          end
        end

        describe '#position_of' do
          context 'value is present' do
            it 'returns index' do
              array = [1, 3, 7]
              result = described_class.position_of(array, 1)
              expect(result).to eq([true, 0])
              result = described_class.position_of(array, 3)
              expect(result).to eq([true, 1])
              result = described_class.position_of(array, 7)
              expect(result).to eq([true, 2])
            end
          end

          context 'value is minimum' do
            it 'returns 0' do
              array = [1, 3, 7]
              result = described_class.position_of(array, -1)
              expect(result).to eq([false, 0])
            end
          end

          context 'value is maximum' do
            it 'returns length' do
              array = [1, 3, 7]
              result = described_class.position_of(array, 11)
              expect(result).to eq([false, 3])
            end
          end

          context 'value is in between' do
            it 'returns insert point' do
              array = [1, 3, 7]
              result = described_class.position_of(array, 2)
              expect(result).to eq([false, 1])
              result = described_class.position_of(array, 5)
              expect(result).to eq([false, 2])
            end
          end
        end
      end
    end
  end
end
