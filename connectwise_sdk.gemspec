# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'connectwise/version'

Gem::Specification.new do |spec|
  spec.name          = "connectwise_sdk"
  spec.version       = Connectwise::VERSION
  spec.authors       = ["Emery A. Miller"]
  spec.email         = ["emery.miller@easyofficephone.com"]
  spec.description   = %q{This Gem is an SDK for accessing Connectwise}
  spec.summary       = %q{A Connectwise SDK for Ruby}
  spec.homepage      = "http://github.com/EasyOfficePhone/connectwise-sdk"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~>10.3"
  spec.add_development_dependency "rspec", "~>3.0"

  spec.add_runtime_dependency "savon", "~> 2.0"
end
