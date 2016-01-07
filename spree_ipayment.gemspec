# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spree_ipayment/version', __FILE__)

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["Hubert Hoelzl"]
  gem.email         = ["info@sketchit.de"]
  gem.description   = %q{Payment Method for iPayment for Spree Commerce}
  gem.summary       = %q{Spree Extension for iPayment}
  gem.homepage      = "https://github.com/23tux/spree_ipayment"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spree_ipayment"
  gem.require_paths = ["lib"]
  gem.version       = SpreeIpayment::VERSION

  gem.add_dependency('spree_core', '>=1.2.0')
  gem.add_dependency('savon', '~> 2.11.0')
  gem.add_development_dependency 'rspec-rails'
end
