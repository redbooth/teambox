require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

load File.join(File.dirname(__FILE__), 'tasks', 'localized_country_select_tasks.rake')

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the localized_country_select plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the localized_country_select plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LocalizedCountrySelect'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
