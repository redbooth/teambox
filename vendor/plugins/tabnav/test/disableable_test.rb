require File.dirname(__FILE__) + '/test_helper'

class MyDisablingObject
  include Widgets::Disableable
end

class DisableableTest < Test::Unit::TestCase
  
  EXPECTED_INSTANCE_METHODS = %w{disabled_condition disabled_condition= disabled? disabled_if}
  
  def setup    
    @obj = MyDisablingObject.new
  end
     
  def test_included_methods
    EXPECTED_INSTANCE_METHODS.each do |method|
      assert @obj.respond_to?(method), "A disableable object should respond to '#{method}'"
    end
  end
  
  def test_accessor
    assert @obj.disabled_condition.kind_of?(Proc)
  end
  
  def test_disabled_if
    disabled_proc = proc { 1 == 1 }
    @obj.disabled_condition = disabled_proc
    assert @obj.disabled_condition.kind_of?(Proc)
  end
  
  def test_disabled?
    @obj.disabled_if proc { 1 == 1 }
    assert @obj.disabled?, 'should be disabled'
  end

  def test_default_disabled?
    assert !@obj.disabled?, 'should not be disabled'
  end
end
