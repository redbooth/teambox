require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/permalink_fu')

begin
  require 'rubygems'
  require 'ruby-debug'
  Debugger.start
rescue LoadError
  puts "no ruby debugger"
end

gem 'activesupport'
require 'active_support/core_ext/blank'

class FauxColumn < Struct.new(:limit)
end

class BaseModel
  def self.columns_hash
    @columns_hash ||= {'permalink' => FauxColumn.new(100)}
  end

  def self.inherited(base)
    subclasses << base
  end

  extend PermalinkFu::PluginMethods
  attr_accessor :id
  attr_accessor :title
  attr_accessor :extra
  attr_reader   :permalink
  attr_accessor :foo

  class << self
    attr_accessor :validation, :subclasses
  end
  self.subclasses = []

  def self.generated_methods
    @generated_methods ||= []
  end
  
  def self.primary_key
    :id
  end
  
  def self.logger
    nil
  end

  def self.define_attribute_methods
    return unless generated_methods.empty?
    true
  end

  # ripped from AR
  def self.evaluate_attribute_method(attr_name, method_definition, method_name=attr_name)

    unless method_name.to_s == primary_key.to_s
      generated_methods << method_name
    end

    begin
      class_eval(method_definition, __FILE__, __LINE__)
    rescue SyntaxError => err
      generated_methods.delete(attr_name)
      if logger
        logger.warn "Exception occurred during reader method compilation."
        logger.warn "Maybe #{attr_name} is not a valid Ruby identifier?"
        logger.warn "#{err.message}"
      end
    end
  end

  def self.exists?(*args)
    false
  end

  def self.before_validation(method)
    self.validation = method
  end

  def validate
    send self.class.validation if self.class.validation
    permalink
  end
  
  def new_record?
    @id.nil?
  end
  
  def write_attribute(key, value)
    instance_variable_set "@#{key}", value
  end
  
  def read_attribute(key)
    instance_variable_get "@#{key}"
  end
end

class MockModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo'   || conditions[1] == 'bar' || 
      (conditions[1] == 'bar-2' && conditions[2] != 2)
      true
    else
      false
    end
  end

  has_permalink :title
end

class PermalinkChangeableMockModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo'
      true
    else
      false
    end
  end

  has_permalink :title

  def permalink_changed?
    @permalink_changed
  end

  def permalink_will_change!
    @permalink_changed = true
  end
end

class CommonMockModel < BaseModel
  def self.exists?(conditions)
    false # oh noes
  end

  has_permalink :title, :unique => false
end

class ScopedModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo' && conditions[2] != 5
      true
    else
      false
    end
  end

  has_permalink :title, :scope => :foo
end

class ScopedModelForNilScope < BaseModel
  def self.exists?(conditions)
    (conditions[0] == 'permalink = ? and foo IS NULL') ? (conditions[1] == 'ack') : false
  end

  has_permalink :title, :scope => :foo
end

class OverrideModel < BaseModel
  has_permalink :title
  
  def permalink
    'not the permalink'
  end
end

class ChangedWithoutUpdateModel < BaseModel
  has_permalink :title  
  def title_changed?; true; end
end

class ChangedWithUpdateModel < BaseModel
  has_permalink :title, :update => true 
  def title_changed?; true; end
end

class NoChangeModel < BaseModel
  has_permalink :title, :update => true
  def title_changed?; false; end
end

class IfProcConditionModel < BaseModel
  has_permalink :title, :if => Proc.new { |obj| false }
end

class IfMethodConditionModel < BaseModel
  has_permalink :title, :if => :false_method
  
  def false_method; false; end
end

class IfStringConditionModel < BaseModel
  has_permalink :title, :if => 'false'
end

class UnlessProcConditionModel < BaseModel
  has_permalink :title, :unless => Proc.new { |obj| false }
end

class UnlessMethodConditionModel < BaseModel
  has_permalink :title, :unless => :false_method
  
  def false_method; false; end
end

class UnlessStringConditionModel < BaseModel
  has_permalink :title, :unless => 'false'
end

class MockModelExtra < BaseModel
  has_permalink [:title, :extra]
end

# trying to be like ActiveRecord, define the attribute methods manually
BaseModel.subclasses.each { |c| c.send :define_attribute_methods }

class PermalinkFuTest < Test::Unit::TestCase
  @@samples = {
    'This IS a Tripped out title!!.!1  (well/ not really)'.freeze => 'this-is-a-tripped-out-title1-well-not-really'.freeze,
    '////// meph1sto r0x ! \\\\\\'.freeze => 'meph1sto-r0x'.freeze,
    'āčēģīķļņū'.freeze => 'acegiklnu'.freeze,
    '中文測試 chinese text'.freeze => 'chinese-text'.freeze,
    'fööbär'.freeze => 'foobar'.freeze
  }

  @@extra = { 'some-)()()-ExtRa!/// .data==?>    to \/\/test'.freeze => 'some-extra-data-to-test'.freeze }

  def test_should_escape_permalinks
    @@samples.each do |from, to|
      assert_equal to, PermalinkFu.escape(from)
    end
  end
  
  def test_should_escape_activerecord_model
    @m = MockModel.new
    @@samples.each do |from, to|
      @m.title = from; @m.permalink = nil
      assert_equal to, @m.validate
    end
  end
  
  def test_should_escape_activerecord_model_with_existing_permalink
    @m = MockModel.new
    @@samples.each do |from, to|
      @m.title = 'whatever'; @m.permalink = from
      assert_equal to, @m.validate
    end
  end
  
  def test_multiple_attribute_permalink
    @m = MockModelExtra.new
    @@samples.each do |from, to|
      @@extra.each do |from_extra, to_extra|
        @m.title = from; @m.extra = from_extra; @m.permalink = nil
        assert_equal "#{to}-#{to_extra}", @m.validate
      end
    end
  end

  def test_should_create_unique_permalink
    @m = MockModel.new
    @m.title = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
    
    @m.title = 'bar'
    @m.permalink = nil
    @m.validate
    assert_equal 'bar-3', @m.permalink
  end
  
  def test_should_create_unique_permalink_when_assigned_directly
    @m = MockModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
    
    # should always check itself for uniqueness when not respond_to?(:permalink_changed?)
    @m.permalink = 'bar'
    @m.validate
    assert_equal 'bar-3', @m.permalink
  end
  
  def test_should_common_permalink_if_unique_is_false
    @m = CommonMockModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo', @m.permalink
  end
  
  def test_should_not_check_itself_for_unique_permalink
    @m = MockModel.new
    @m.id = 2
    @m.permalink = 'bar-2'
    @m.validate
    assert_equal 'bar-2', @m.permalink
  end

  def test_should_check_itself_for_unique_permalink_if_permalink_field_changed
    @m = PermalinkChangeableMockModel.new
    @m.permalink_will_change!
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
  end

  def test_should_not_check_itself_for_unique_permalink_if_permalink_field_not_changed
    @m = PermalinkChangeableMockModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo', @m.permalink
  end
  
  def test_should_create_unique_scoped_permalink
    @m = ScopedModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
  
    @m.foo = 5
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo', @m.permalink
  end
  
  def test_should_limit_permalink
    @old = MockModel.columns_hash['permalink'].limit
    MockModel.columns_hash['permalink'].limit = 2
    @m   = MockModel.new
    @m.title = 'BOO'
    assert_equal 'bo', @m.validate
  ensure
    MockModel.columns_hash['permalink'].limit = @old
  end
  
  def test_should_limit_unique_permalink
    @old = MockModel.columns_hash['permalink'].limit
    MockModel.columns_hash['permalink'].limit = 3
    @m   = MockModel.new
    @m.title = 'foo'
    assert_equal 'f-2', @m.validate
  ensure
    MockModel.columns_hash['permalink'].limit = @old
  end
  
  def test_should_abide_by_if_proc_condition
    @m = IfProcConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_if_method_condition
    @m = IfMethodConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_if_string_condition
    @m = IfStringConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_unless_proc_condition
    @m = UnlessProcConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
  
  def test_should_abide_by_unless_method_condition
    @m = UnlessMethodConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
  
  def test_should_abide_by_unless_string_condition
    @m = UnlessStringConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
  
  def test_should_allow_override_of_permalink_method
    @m = OverrideModel.new
    @m.write_attribute(:permalink, 'the permalink')
    assert_not_equal @m.permalink, @m.read_attribute(:permalink)
  end
  
  def test_should_create_permalink_from_attribute_not_attribute_accessor
    @m = OverrideModel.new
    @m.title = 'the permalink'
    @m.validate
    assert_equal 'the-permalink', @m.read_attribute(:permalink)
  end
  
  def test_should_not_update_permalink_unless_field_changed
    @m = NoChangeModel.new
    @m.title = 'the permalink'
    @m.permalink = 'unchanged'
    @m.validate
    assert_equal 'unchanged', @m.read_attribute(:permalink)
  end
  
  def test_should_not_update_permalink_without_update_set_even_if_field_changed
    @m = ChangedWithoutUpdateModel.new
    @m.title = 'the permalink'
    @m.permalink = 'unchanged'
    @m.validate
    assert_equal 'unchanged', @m.read_attribute(:permalink)
  end
  
  def test_should_update_permalink_if_changed_method_does_not_exist
    @m = OverrideModel.new
    @m.title = 'the permalink'
    @m.validate
    assert_equal 'the-permalink', @m.read_attribute(:permalink)
  end

  def test_should_update_permalink_if_the_existing_permalink_is_nil
    @m = NoChangeModel.new
    @m.title = 'the permalink'
    @m.permalink = nil
    @m.validate
    assert_equal 'the-permalink', @m.read_attribute(:permalink)
  end

  def test_should_update_permalink_if_the_existing_permalink_is_blank
    @m = NoChangeModel.new
    @m.title = 'the permalink'
    @m.permalink = ''
    @m.validate
    assert_equal 'the-permalink', @m.read_attribute(:permalink)
  end

  def test_should_assign_a_random_permalink_if_the_title_is_nil
    @m = NoChangeModel.new
    @m.title = nil
    @m.validate
    assert_not_nil @m.read_attribute(:permalink)
    assert @m.read_attribute(:permalink).size > 0
  end

  def test_should_assign_a_random_permalink_if_the_title_has_no_permalinkable_characters
    @m = NoChangeModel.new
    @m.title = '////'
    @m.validate
    assert_not_nil @m.read_attribute(:permalink)
    assert @m.read_attribute(:permalink).size > 0
  end

  def test_should_update_permalink_the_first_time_the_title_is_set
    @m = ChangedWithoutUpdateModel.new
    @m.title = "old title"
    @m.validate
    assert_equal "old-title", @m.read_attribute(:permalink)
    @m.title = "new title"
    @m.validate
    assert_equal "old-title", @m.read_attribute(:permalink)
  end

  def test_should_not_update_permalink_if_already_set_even_if_title_changed
    @m = ChangedWithoutUpdateModel.new
    @m.permalink = "old permalink"
    @m.title = "new title"
    @m.validate
    assert_equal "old-permalink", @m.read_attribute(:permalink)
  end

  def test_should_update_permalink_every_time_the_title_is_changed
    @m = ChangedWithUpdateModel.new
    @m.title = "old title"
    @m.validate
    assert_equal "old-title", @m.read_attribute(:permalink)
    @m.title = "new title"
    @m.validate
    assert_equal "new-title", @m.read_attribute(:permalink)
  end
  
  def test_should_work_correctly_for_scoped_fields_with_nil_value
    s1 = ScopedModelForNilScope.new
    s1.title = 'ack'
    s1.foo = 3
    s1.validate
    assert_equal 'ack', s1.permalink
    
    s2 = ScopedModelForNilScope.new
    s2.title = 'ack'
    s2.foo = nil
    s2.validate
    assert_equal 'ack-2', s2.permalink
  end
end
