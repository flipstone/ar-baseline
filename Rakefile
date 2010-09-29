gem 'rspec', :version => ">= 1.3.0"

require 'rake/gempackagetask'
require 'spec/rake/spectask'

task :default => "spec"

desc "run specs"
Spec::Rake::SpecTask.new("spec") do |t|
  # t.libs << ["spec"]
  # t.spec_opts = ["--format", "nested"]
  t.spec_files = FileList["spec//**/*_spec.rb"]
end

specification = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
	s.name   = "ar-baseline"
  s.summary = "Collapse your migration history and data in one wonderful package."
	s.version = "0.1.0"
	s.author = "David Vollbracht"
	s.description = s.summary
	s.email = "david.vollbracht@gmail.com"

  s.has_rdoc = false
  #s.extra_rdoc_files = ['README.rdoc', 'CHANGELOG']
  #s.rdoc_options << '--title' << "ar-baseline" << '--main' << 'README.rdoc' << '--line-numbers'

  s.files = FileList['{lib,spec,script}/**/*.{rb,rake}', 'Rakefile'].to_a
end

Rake::GemPackageTask.new(specification) do |package|
end

Rake::Task[:gem].prerequisites.unshift :default
