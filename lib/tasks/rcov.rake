unless Teambox.config.heroku?
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

  namespace :rcov do
    Cucumber::Rake::Task.new(:cucumber_run) do |t|
      t.rcov = true
      t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
      t.rcov_opts << %[-o "coverage"]
    end

    RSpec::Core::RakeTask.new(:rspec_run) do |t|
      t.pattern = 'spec/**/*_spec.rb'
      t.rcov = true
      t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
      t.rcov_opts << %[-o "coverage"]
    end

    desc "Run both specs and features to generate aggregated coverage"
    task :all do |t|
      rm "coverage.data" if File.exist?("coverage.data")
      Rake::Task["rcov:cucumber_run"].invoke
      Rake::Task["rcov:rspec_run"].invoke
    end
  end
end