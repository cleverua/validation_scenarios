require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the validation_scenarios plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the validation_scenarios plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidationScenarios'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Creates 'validation-scenario' tag in plugins' SVN"
task :create_tag do
  system "svn rm https://validation-scenarios.googlecode.com/svn/tags/validation-scenarios -m 'removed'"
  system "svn copy https://validation-scenarios.googlecode.com/svn/trunk https://validation-scenarios.googlecode.com/svn/tags/validation-scenarios -m 'Tagging, to be able to use script/plugin install'"
end

