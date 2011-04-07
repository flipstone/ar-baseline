# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
	s.name   = "ar-baseline"
  s.summary = "Collapse your migration history and data in one wonderful package."
	s.version = "0.1.0"
  s.authors     = ["David Vollbracht"]
  s.email       = ["david@flipstone.com"]
	s.description = %{}
  s.add_dependency 'activerecord', '~> 3.0'

  s.has_rdoc = false

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

