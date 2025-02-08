# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements collection' do
      describe 'querying methods' do
        it 'returns number of elements in collection for each of `size`, `length` and `count`' do
          expect(non_empty_collection.size).to eq(expected_size)
          expect(non_empty_collection.length).to eq(expected_size)
          expect(non_empty_collection.count).to eq(expected_size)
        end
      end

      describe 'empty?' do
        it 'returns true if collection is empty, false otherwise' do
          expect(empty_collection).to be_empty
          expect(non_empty_collection).not_to be_empty
        end
      end
    end
  end
end
