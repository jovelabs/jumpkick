# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jumpkick/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary.patten@homerun.com"]
  gem.description   = %q{Jumpkick, an automated provisioning system.}
  gem.summary       = %q{Demaindchain's automated provisioning system.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jumpkick"
  gem.require_paths = ["lib"]
  gem.version       = Jumpkick::VERSION

  gem.add_dependency("chef", "~> 0.10.8")
  gem.add_dependency("fog", ">= 0")
end
