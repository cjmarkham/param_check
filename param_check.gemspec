# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'param_check/version'

Gem::Specification.new do |spec|
  spec.name          = "param_check"
  spec.version       = ParamCheck::VERSION
  spec.authors       = ["cjmarkham"]
  spec.email         = ["doddsey65@gmail.com"]

  spec.summary       = %q{Validate parameters for Rails API methods}
  spec.description   = %q{Validate parameters presence and type for Rails API methods}
  spec.homepage      = "https://cjmarkham.co.uk"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 5.0.0.1"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
