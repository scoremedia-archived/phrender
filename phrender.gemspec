# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phrender/version'

Gem::Specification.new do |spec|
  spec.name          = "phrender"
  spec.version       = Phrender::VERSION
  spec.authors       = ["M Smart, theScore Inc."]
  spec.email         = ["matthew.smart@thescore.com"]
  spec.description   = %q{Rack server for rendering javascript apps for bots}
  spec.summary       = %q{Rack server for rendering javascript apps for bots}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", "~> 1.5.2"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 3.0.0.beta1'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'sprockets'
  spec.add_development_dependency 'pry', '0.9.12.2'
end
