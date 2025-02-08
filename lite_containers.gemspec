# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/lite/containers/version'

Gem::Specification.new do |spec|
  spec.name          = 'lite-containers'
  spec.version       = Lite::Containers::VERSION
  spec.authors       = ['Tomas Milsimer']
  spec.email         = ['tomas.milsimer@protonmail.com']

  spec.summary       = 'A collection of containers: heap, sorted array, AVL tree'
  spec.homepage      = 'https://github.com/lame-impala/lite-containers'
  spec.metadata['homepage_uri'] = spec.homepage

  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.3'
end
