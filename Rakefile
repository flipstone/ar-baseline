gem 'rspec', :version => ">= 1.3.0"

require 'spec/rake/spectask'

task :default => "spec"

desc "run specs"
Spec::Rake::SpecTask.new("spec") do |t|
  # t.libs << ["spec"]
  # t.spec_opts = ["--format", "nested"]
  t.spec_files = FileList["spec//**/*_spec.rb"]
end

