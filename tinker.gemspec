# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tinker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Guillaume Malette"]
  gem.email         = ["gmalette@gmail.com"]
  gem.description   = %q{Tinker is a prototype for realtime games}
  gem.summary       = %q{Tinker is a prototype for realtime games}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tinker"
  gem.require_paths = ["lib"]
  gem.version       = Tinker::VERSION

  gem.add_dependency "activesupport"
  gem.add_dependency "em-websocket"
  gem.add_dependency "rake"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "pry"
end
