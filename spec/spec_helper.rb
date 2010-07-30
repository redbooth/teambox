ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__) unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require File.expand_path('../factories', __FILE__)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'email_spec/helpers'
require 'email_spec/matchers'

Spec::Runner.configure do |config|
  config.include AuthenticatedTestHelper, EmailSpec::Helpers, EmailSpec::Matchers

  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

def route_matches(path, method, params)
  it "maps #{params.inspect} to #{path.inspect}" do
    route_for(params).should == {:path => path, :method => method}
  end

  it "generates params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, path).should == params
  end
end

def generate_file(filename, size = 1024)
  File.open(filename,"wb") { |f| f.seek(size-1); f.write("\0") }
end

def mock_uploader(file, type = 'image/png', data=nil)
  uploader = ActionController::UploadedStringIO.new
  unless data.nil?
    uploader.write(data)
    uploader.seek(0)
    uploader.original_path = file
  else
    uploader.original_path = "%s/%s" % [ File.dirname(__FILE__), file ]
    uploader.write(File.read(uploader.original_path))
    uploader.seek(0)
  end
  
  uploader.content_type = type
  uploader
end

def make_a_typical_project
    @user = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @owner = @project.user
    @project.add_user(@user)
    @observer = Factory.create(:confirmed_user)
    @project.add_user(@observer)
    @project.people(true).last.update_attribute(:role, Person::ROLES[:observer])
    @admin = Factory.create(:confirmed_user)
    @project.add_user(@admin)
    @project.people(true).last.update_attribute(:role, Person::ROLES[:admin])
end