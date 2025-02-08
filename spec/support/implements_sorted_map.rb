# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements sorted map' do
      before { min_sorted_map << 5 << 1 << 3 }

      describe '#find' do
        it 'when element is present' do
          [5, 1, 3].each do |searched_key|
            value = min_sorted_map.find(searched_key)
            expect(value).to eq(searched_key)
          end
        end

        context 'when element is missing' do
          it 'returns nil' do
            expect(min_sorted_map.find(4)).to be_nil
          end
        end
      end

      describe '#key?' do
        it 'when element is present' do
          [5, 1, 3].each do |searched_key|
            expect(min_sorted_map.key?(searched_key)).to be(true)
          end
        end

        context 'when element is missing' do
          it 'returns nil' do
            expect(min_sorted_map.key?(4)).to be(false)
          end
        end
      end

      describe '#find_or_nearest_forwards' do
        it 'when element is present' do
          [5, 1, 3].each do |searched_key|
            value = min_sorted_map.find_or_nearest_forwards(searched_key)
            expect(value).to eq(searched_key)
          end
        end

        context 'when element is missing' do
          context 'when higher priority element exists' do
            it 'returns higher priority element' do
              expect(min_sorted_map.find_or_nearest_forwards(4)).to eq(3)
            end
          end

          context 'when element is minimum' do
            it 'returns back' do
              expect(min_sorted_map.find_or_nearest_forwards(7)).to eq(5)
            end
          end

          context 'when element is maximum' do
            it 'returns nil' do
              expect(min_sorted_map.find_or_nearest_forwards(0)).to be_nil
            end
          end
        end
      end

      describe '#find_or_nearest_backwards' do
        it 'when element is present' do
          [5, 1, 3].each do |searched_key|
            expect(min_sorted_map.find_or_nearest_backwards(searched_key)).to eq(searched_key)
          end
        end

        context 'when element is missing' do
          context 'when lower priority element exists' do
            it 'returns lower priority element' do
              expect(min_sorted_map.find_or_nearest_backwards(4)).to eq(5)
            end
          end

          context 'when element is maximum' do
            it 'returns front' do
              expect(min_sorted_map.find_or_nearest_backwards(0)).to eq(1)
            end
          end

          context 'when element is minimum' do
            it 'returns nil' do
              expect(min_sorted_map.find_or_nearest_backwards(6)).to be_nil
            end
          end
        end
      end
    end
  end
end
