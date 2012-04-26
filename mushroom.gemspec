# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mushroom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ivan Vanderbyl"]
  gem.email         = ["ivanvanderbyl@me.com"]
  gem.description   = %q{Super simple events and instrumentation within your ruby app}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/ivanvanderbyl/mushroom"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mushroom"
  gem.require_paths = ["lib"]
  gem.version       = Mushroom::VERSION

  gem.add_dependency "activesupport", ">= 3.0.0"

  gem.add_development_dependency "rspec", ">= 2.8.0"
end
