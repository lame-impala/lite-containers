# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/lite/containers/avl_tree/node'

RSpec::Matchers.define :have_structure do |structure|
  match do |node|
    @errors = match_structure(node, structure)
    @errors.empty?
  end

  def match_structure(node, structure, result = {})
    errors = []
    errors << "expected key '#{structure[:k]}', got '#{node.key}'" if structure[:k] != node.key
    errors << "expected value '#{structure[:v]}', got '#{node.value}'" if structure[:v] && structure[:v] != node.value
    if structure[:h] && structure[:h] != node.height
      errors << "expected height '#{structure[:h]}', got '#{node.height}'"
    end
    errors << "expected left to be present but it wasn't" if structure[:l] && !node.left
    errors << 'expected left not to be present but it was' if !structure[:l] && node.left
    errors << "expected right to be present but it wasn't" if structure[:r] && !node.right
    errors << 'expected right not to be present but it was' if !structure[:r] && node.right
    result = result.merge(node.key => errors) unless errors.empty?
    result = match_structure(node.left, structure[:l], result) if node.left && structure[:l]
    result = match_structure(node.right, structure[:r], result) if node.right && structure[:r]
    result
  end

  failure_message do
    "There were unmatched nodes -- #{@errors.map do |key, errors|
      "errors for '#{key}': #{errors.join(', ')}"
    end.join(' -- ')}"
  end
end

module Lite
  module Containers
    class AvlTree
      RSpec.shared_context 'balanced node' do
        let(:balanced) do
          node = AvlTree::Node.instance(20, 'foo').tap { |node| node.height = 3 }
          node.left = AvlTree::Node.instance(8, 'bar').tap { |left| left.height = 2 }
          node.left.left = AvlTree::Node.instance(4, 'baz').tap { |left| left.height = 1 }
          node.left.right = AvlTree::Node.instance(12, 'bax').tap { |left| left.height = 1 }
          node.right = AvlTree::Node.instance(28, 'qoo').tap { |right| right.height = 2 }
          node.right.left = AvlTree::Node.instance(24, 'qox').tap { |right| right.height = 1 }
          node.right.right = AvlTree::Node.instance(32, 'qoz').tap { |right| right.height = 1 }
          node
        end
      end

      RSpec.shared_context 'right right unbalanced node' do
        let(:balanced) do
          node = AvlTree::Node.instance(5, 'foo').tap { |node| node.height = 3 }
          node.left = AvlTree::Node.instance(4, 'bar').tap { |left| left.height = 1 }
          node.right = AvlTree::Node.instance(7, 'bax').tap { |right| right.height = 2 }
          node.right.left = AvlTree::Node.instance(6, 'baz').tap { |right| right.height = 1 }
          node.right.right = AvlTree::Node.instance(8, 'qax').tap { |right| right.height = 1 }
          node
        end

        let(:right_right_unbalanced) do
          balanced.height = 4
          balanced.right.height = 3
          balanced.right.right.height = 2
          balanced.right.right.right = AvlTree::Node.instance(9, 'qaz').tap { |right| right.height = 1 }
          balanced
        end
      end

      RSpec.shared_context 'left left unbalanced node' do
        let(:balanced) do
          node = AvlTree::Node.instance(5, 'foo').tap { |node| node.height = 3 }
          node.right = AvlTree::Node.instance(6, 'bar').tap { |left| left.height = 1 }
          node.left = AvlTree::Node.instance(3, 'bax').tap { |right| right.height = 2 }
          node.left.right = AvlTree::Node.instance(4, 'baz').tap { |right| right.height = 1 }
          node.left.left = AvlTree::Node.instance(2, 'qax').tap { |right| right.height = 1 }
          node
        end

        let(:left_left_unbalanced) do
          balanced.height = 4
          balanced.left.height = 3
          balanced.left.left.height = 2
          balanced.left.left.left = AvlTree::Node.instance(1, 'qaz').tap { |right| right.height = 1 }
          balanced
        end
      end

      RSpec.shared_context 'right left unbalanced node' do
        let(:balanced) do
          node = AvlTree::Node.instance(5, 'foo').tap { |node| node.height = 3 }
          node.left = AvlTree::Node.instance(4, 'bar').tap { |left| left.height = 1 }
          node.right = AvlTree::Node.instance(8, 'bax').tap { |right| right.height = 2 }
          node.right.left = AvlTree::Node.instance(7, 'qax').tap { |right| right.height = 1 }
          node.right.right = AvlTree::Node.instance(9, 'qaz').tap { |right| right.height = 1 }
          node
        end

        let(:right_left_unbalanced) do
          balanced.height = 4
          balanced.right.height = 3
          balanced.right.left.height = 2
          balanced.right.left.left = AvlTree::Node.instance(6, 'baz').tap { |right| right.height = 1 }
          balanced
        end
      end

      RSpec.shared_context 'left right unbalanced node' do
        let(:balanced) do
          node = AvlTree::Node.instance(5, 'foo').tap { |node| node.height = 3 }
          node.right = AvlTree::Node.instance(6, 'bar').tap { |left| left.height = 1 }
          node.left = AvlTree::Node.instance(2, 'bax').tap { |right| right.height = 2 }
          node.left.right = AvlTree::Node.instance(3, 'baz').tap { |right| right.height = 1 }
          node.left.left = AvlTree::Node.instance(1, 'qax').tap { |right| right.height = 1 }
          node
        end

        let(:left_right_unbalanced) do
          balanced.height = 4
          balanced.left.height = 3
          balanced.left.right.height = 2
          balanced.left.right.right = AvlTree::Node.instance(4, 'qaz').tap { |right| right.height = 1 }
          balanced
        end
      end
    end
  end
end
