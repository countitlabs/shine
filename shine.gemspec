# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shine/version'

Gem::Specification.new do |spec|
  spec.name          = "shine"
  spec.version       = Shine::VERSION
  spec.authors       = ["Mathias Kolehmainen"]
  spec.email         = ["mathias@countit.com"]
  spec.description   = %q{Ruby client for Misfit/Shine}
  spec.summary       = %q{Ruby client for Misfit/Shine}
  spec.homepage      = "https://github.com/socialworkout/shine"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.12"

  spec.add_development_dependency "bundler", "~> 1.3"
  #spec.add_development_dependency "rake"
  #spec.add_development_dependency "minitest"
end
