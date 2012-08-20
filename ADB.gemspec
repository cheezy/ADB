# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ADB/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeffrey S. Morgan", "Joel Byler"]
  gem.email         = ["jeff.morgan@leandog.com", "joelbyler@gmail.com"]
  gem.description   = %q{Simple wrapper over Android Debug Bridge command-line tool}
  gem.summary       = %q{Simple wrapper over Android Debug Bridge command-line tool}
  gem.homepage      = "http://github.com/cheezy/ADB"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ADB"
  gem.require_paths = ["lib"]
  gem.version       = ADB::VERSION
  
  gem.add_dependency 'childprocess', '>= 0.3.5'
  
  gem.add_development_dependency 'rspec', '>= 2.11.0'
  gem.add_development_dependency 'cucumber', '>= 1.2.0'

end
