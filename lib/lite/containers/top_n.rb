# frozen_string_literal: true

require_relative 'error'

module Lite
  module Containers
    module TopN
      def self.register_backend(name, backend)
        registry[name] = backend
      end

      def self.registry
        @registry ||= {}
      end

      def self.instance(backend, type, limit: nil, filter: nil, **backend_options)
        limit = Integer(limit) unless limit.nil?
        raise Error, "Expected positive integer or nil for limit, got '#{limit}'" unless limit.nil? || limit.positive?

        wrapper_class = wrapper_class(backend)
        wrapper_class.instance type, limit: limit, filter: filter, **backend_options
      end

      def self.wrapper_class(name)
        raise Error, "Unexpected backend: #{name}" unless registry.key?(name)

        registry[name]
      end
    end
  end
end
