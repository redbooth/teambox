require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'active_record'
require 'action_controller'

begin
  require 'ruby-debug'
rescue LoadError
  puts "ruby-debug not loaded"
end

ROOT       = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'completeness-fu')

require File.join(ROOT, 'lib', 'completeness-fu.rb')


TEST_DATABASE_FILE = File.join(ROOT, 'test', 'test.sqlite3')

File.unlink(TEST_DATABASE_FILE) if File.exist?(TEST_DATABASE_FILE)
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", "database" => TEST_DATABASE_FILE
)

RAILS_DEFAULT_LOGGER = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

load(File.dirname(__FILE__) + '/schema.rb')


I18n.load_path << File.join(ROOT, 'test', 'en.yml')


def rebuild_class options = {}
  ActiveRecord::Base.send(:include, CompletenessFu::ActiveRecordAdditions)
  Object.send(:remove_const, "ScoringTest") rescue nil
  Object.const_set("ScoringTest", Class.new(ActiveRecord::Base))
  ScoringTest.class_eval do
    include CompletenessFu::ActiveRecordAdditions
    define_completeness_scoring do
      check :title, lambda { |test| test.title.present? }, 20
    end
  end
end

def reset_class class_name
  ActiveRecord::Base.send(:include, CompletenessFu::ActiveRecordAdditions)
  Object.send(:remove_const, class_name) rescue nil
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
  klass.class_eval{ include CompletenessFu::ActiveRecordAdditions }
  klass
end
