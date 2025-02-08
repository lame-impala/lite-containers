# frozen_string_literal: true

require 'spec_helper'

module Lite
  module Containers
    RSpec.shared_examples 'implements enumerable' do
      describe '#each' do
        context 'with block' do
          it 'performs block and returns self' do
            accumulator = []
            retval = enumerable.each { accumulator << _1 }
            expect(retval).to be(enumerable)
            expect(accumulator).to eq(expected_accumulator)
          end

          context 'without block' do
            it 'returns enumerator' do
              enumerator = enumerable.each
              accumulator = enumerator.map { _1 }
              expect(accumulator).to eq(expected_accumulator)
            end
          end
        end
      end

      describe '#reverse_each' do
        context 'with block' do
          it 'performs block and returns self' do
            accumulator = []
            retval = enumerable.reverse_each { accumulator << _1 }
            expect(retval).to be(enumerable)
            expect(accumulator).to eq(expected_accumulator.reverse)
          end

          context 'without block' do
            it 'returns enumerator' do
              enumerator = enumerable.each
              accumulator = []
              enumerator.reverse_each { accumulator << _1 }
              expect(accumulator).to eq(expected_accumulator.reverse)
            end
          end
        end
      end
    end
  end
end
