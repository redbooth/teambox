require File.dirname(__FILE__) + '/test_helper'

class MyHighlightingObject
  include Widgets::Highlightable
end

class HighlightableTest < Test::Unit::TestCase
  
  EXPECTED_INSTANCE_METHODS = %w{highlights highlights= highlighted? highlights_on}
  
  def setup    
    @obj = MyHighlightingObject.new
  end
     
  def test_included_methods
    EXPECTED_INSTANCE_METHODS.each do |method|
      assert @obj.respond_to?(method), "An Highlightable object should respond to '#{method}'"
    end
  end
  
  def test_accessor
    assert_equal [], @obj.highlights, 'should return an empty array'
  end
  
  def test_highlights_on
    @obj.highlights=[ {:action => 'my_action'}, {:action => 'my_action2', :controller => 'my_controller'}]
    assert @obj.highlights.kind_of?(Array)
    assert_equal 2, @obj.highlights.size, '2 highlights were added so far'
    
    @obj.highlights.each {|hl| assert hl.kind_of?(Hash)}
    
    # sanity check
    assert_equal 'my_action',@obj.highlights[0][:action] 
  end
  
  def test_highlights_on_proc
    @bonus_points = 0
    @obj.highlights_on proc {@bonus_points > 5}
    assert !@obj.highlighted?, 'should not highlight until @bonus_points is greater than 5'
    
    @bonus_points = 10
    assert @obj.highlighted?, 'should highlight because @bonus_points is greater than 5'
  end
  
  def test_highlight_on_string
    @obj.highlights_on "http://www.seesaw.it"
    
  end
    
  def test_highlighted?
    @obj.highlights_on :controller => 'pippo'
    
    #check that highlights on its own link
    assert @obj.highlighted?(:controller => 'pippo'), 'should highlight'
    assert @obj.highlighted?(:controller => 'pippo', :action => 'list'), 'should highlight'
    assert !@obj.highlighted?(:controller => 'pluto', :action => 'list'), 'should NOT highlight'

  end
  
  def test_more_highlighted?
    # add some other highlighting rules
    # and check again
    @obj.highlights=[{:controller => 'pluto'}]
    assert @obj.highlighted?(:controller => 'pluto'), 'should highlight'
  
    @obj.highlights << {:controller => 'granny', :action => 'oyster'}
    assert @obj.highlighted?(:controller => 'granny', :action => 'oyster'), 'should highlight' 
    assert !@obj.highlighted?(:controller => 'granny', :action => 'daddy'), 'should NOT highlight'   
  end
  
  def test_highlighted_with_slash
    @obj.highlights_on :controller => '/pippo'
    assert @obj.highlighted?({:controller => 'pippo'})
  end

end