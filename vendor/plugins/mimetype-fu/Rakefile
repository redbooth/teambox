require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mimetype-fu"
    gem.summary = "get the mimetype of a file directly in Ruby"
    gem.description = "get the mimetype of a file directly in Ruby"
    gem.email = "josh@vitamin-j.com"
    gem.homepage = "http://github.com/jfrench/mimetype-fu"
    gem.authors = ["Josh French"]
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc 'Default: run unit tests.'
task :default => :spec

desc 'Test the mimetype_fu plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the mimetype_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MimetypeFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Run the RSpec tests.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end
