# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_analyze/version'

Gem::Specification.new do |spec|
  spec.name          = "git_analyze"
  spec.version       = GitAnalyze::VERSION
  spec.authors       = ["Aaron Neyer"]
  spec.email         = ["aaronneyer@gmail.com"]
  spec.description   = %q{analyzes git}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "github_api"
  spec.add_dependency "alchemy-api"
end
