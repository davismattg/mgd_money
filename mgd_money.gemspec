# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mgd_money/version"

Gem::Specification.new do |spec|
  spec.name          = "mgd_money"
  spec.version       = MgdMoney::VERSION
  spec.authors       = ["Matt Davis"]
  spec.email         = ["davismattg@gmail.com"]

  spec.summary       = "MGDMoney"
  spec.description   = "A simple gem to enable conversion between different currencies"
  spec.homepage      = "http://www.mattgdavis.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
