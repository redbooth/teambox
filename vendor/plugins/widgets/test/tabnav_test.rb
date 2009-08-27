require File.dirname(__FILE__) + '/test_helper'

class TabnavTest < Test::Unit::TestCase
  include Widgets
  
  def setup
    @tabnav = Tabnav.new :sample
  end
  
  def test_default_html_options
    assert_equal 'sample_tabnav', @tabnav.html[:id]
    assert_equal 'sample_tabnav', @tabnav.html[:class]
  end  
end