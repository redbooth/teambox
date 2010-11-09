# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

  begin
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

      task :statsetup do
        require 'code_statistics'
        ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
        ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
        ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
        ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
        ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
        ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
        ::STATS_DIRECTORIES << %w(Integration\ specs spec/integration) if File.exist?('spec/integration')
        ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
        ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
        ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
        ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
        ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
        ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
        ::CodeStatistics::TEST_TYPES << "Integration specs" if File.exist?('spec/integration')
        ::STATS_DIRECTORIES << %w(Cucumber\ features features) if File.exist?('features')
        ::CodeStatistics::TEST_TYPES << "Cucumber features" if File.exist?('features')
      end
    end

  # Don't kill rake if rspec is not installed (e.g. in production)
  rescue LoadError
    desc 'rspec is not installed; rake tasks unavailable'
    task :spec do
      abort 'Rspec is not installed, so its rake tasks are not available'
    end
  end

end