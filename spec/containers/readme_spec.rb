# frozen_string_literal: true

require 'spec_helper'
require_relative '../support/readme_helper'

RSpec.describe 'README.md' do # rubocop:disable RSpec/DescribeClass
  # rubocop:disable RSpec/NoExpectationExample, Security/Eval
  describe 'heap documentation' do
    it 'shows correct README example' do
      eval(ReadmeHelper.specs.fetch(:heap))
    end
  end

  describe 'sorted array documentation' do
    it 'shows correct README example' do
      eval(ReadmeHelper.specs.fetch(:sorted_array))
    end
  end

  describe 'implicit key AVL tree documentation' do
    it 'shows correct README example' do
      eval(ReadmeHelper.specs.fetch(:avl_tree_implicit))
    end
  end

  describe 'explicit key AVL tree documentation' do
    it 'shows correct README example' do
      eval(ReadmeHelper.specs.fetch(:avl_tree_explicit))
    end
  end
  # rubocop:enable RSpec/NoExpectationExample, Security/Eval
end
