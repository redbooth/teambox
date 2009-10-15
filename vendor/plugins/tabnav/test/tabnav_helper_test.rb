require File.dirname(__FILE__) + '/test_helper'

class TabnavHelperTest < Test::Unit::TestCase
  include Widgets
  
  EXPECTED_INSTANCE_METHODS = %w{tabnav render_tabnav add_tab}
  def setup
    @view = ActionView::Base.new
    @view.extend ApplicationHelper
    @view.extend TabnavHelper
  end
    
  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert @view.respond_to?(instance_method), "#{instance_method} is not defined in #{@controller.inspect}" 
    end     
  end  
  
end