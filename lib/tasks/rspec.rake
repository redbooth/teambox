# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

  require 'spec/rake/spectask'

  task :stats => "spec:statsetup"

  desc "Run all specs in spec directory (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:spec => "db:test:prepare") do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  namespace :spec do
    desc "Run all specs in spec directory with RCov (excluding plugin specs)"
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList['spec/**/*_spec.rb']
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
      end
    end

    desc "Print Specdoc for all specs (excluding plugin specs)"
    Spec::Rake::SpecTask.new(:doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList['spec/**/*_spec.rb']
    end

    [:models, :controllers, :views, :helpers, :lib, :integration].each do |sub|
      desc "Run the code examples in spec/#{sub}"
      Spec::Rake::SpecTask.new(sub => "db:test:prepare") do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
      end
    end
  end

end
