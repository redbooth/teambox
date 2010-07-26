require 'cucumber/rake/task'

Cucumber::Rake::Task::ForkedCucumberRunner.class_eval do
  alias original_runner runner
  def runner
    cmd = original_runner
    cmd.insert(1, '_0.9.26_') if cmd.first == 'bundle'
    cmd
  end
end

namespace :cucumber do
  Cucumber::Rake::Task.new({:ok => 'db:test:prepare'}, 'Run features that should pass') do |t|
    t.fork = true # You may get faster startup if you set this to false
    t.profile = 'default'
  end

  Cucumber::Rake::Task.new({:wip => 'db:test:prepare'}, 'Run features that are being worked on') do |t|
    t.fork = true # You may get faster startup if you set this to false
    t.profile = 'wip'
  end

  Cucumber::Rake::Task.new({:rerun => 'db:test:prepare'}, 'Record failing features and run only them if any exist') do |t|
    t.fork = true # You may get faster startup if you set this to false
    t.profile = 'rerun'
  end

  desc 'Run all features'
  task :all => [:ok, :wip]
end

desc 'Alias for cucumber:ok'
task :cucumber => 'cucumber:ok'
