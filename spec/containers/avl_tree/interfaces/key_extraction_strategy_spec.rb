# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../lib/lite/containers/avl_tree'
require_relative '../../../../lib/lite/containers/avl_tree/interfaces/bracket_assign'

module Lite
  module Containers
    class AvlTree
      RSpec.describe Interfaces::KeyExtractionStrategy do
        context 'when including both implicit/explicit key extraction strategy' do
          let(:expected_error) do
            'Key extraction strategy conflict: Implicit'
          end

          it 'raises error' do
            expect do
              Class.new do
                include Interfaces::KeyExtractionStrategy::Implicit
                include Interfaces::KeyExtractionStrategy::Explicit
              end
            end.to raise_error(Error, expected_error)
          end
        end

        context 'when including both explicit/implicit key extraction strategy' do
          let(:expected_error) do
            'Key extraction strategy conflict: Explicit'
          end

          it 'raises error' do
            expect do
              Class.new do
                include Interfaces::KeyExtractionStrategy::Explicit
                include Interfaces::KeyExtractionStrategy::Implicit
              end
            end.to raise_error(Error, expected_error)
          end
        end

        context 'when including both implicit key extraction strategy and bracket assign' do
          let(:expected_error) do
            'Key extraction strategy conflict: Implicit'
          end

          it 'raises error' do
            expect do
              Class.new do
                include Interfaces::KeyExtractionStrategy::Implicit
                include Interfaces::BracketAssign
              end
            end.to raise_error(Error, expected_error)
          end
        end

        context 'when including both bracket assign and implicit key extraction strategy' do
          let(:expected_error) do
            'Key extraction strategy conflict: Explicit'
          end

          it 'raises error' do
            expect do
              Class.new do
                include Interfaces::BracketAssign
                include Interfaces::KeyExtractionStrategy::Implicit
              end
            end.to raise_error(Error, expected_error)
          end
        end

        context 'when including both bracket assign and explicit key extraction strategy' do
          let(:expected_error) do
            'Key extraction strategy conflict: Explicit'
          end

          it "doesn't raise error" do
            expect do
              Class.new do
                include Interfaces::BracketAssign
                include Interfaces::KeyExtractionStrategy::Explicit
              end
            end.not_to raise_error
          end
        end

        context 'when including both explicit key extraction strategy and bracket assign' do
          let(:expected_error) do
            'Key extraction strategy conflict: Explicit'
          end

          it "doesn't raise error" do
            expect do
              Class.new do
                include Interfaces::KeyExtractionStrategy::Explicit
                include Interfaces::BracketAssign
              end
            end.not_to raise_error
          end
        end
      end
    end
  end
end
