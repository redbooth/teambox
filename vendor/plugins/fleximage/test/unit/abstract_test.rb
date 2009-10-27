require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageAbstractTest < Test::Unit::TestCase
  
  def test_should_generate_a_default_image
    p = Abstract.new
    assert p.save
    assert_equal 320, p.load_image.columns
    assert_equal 240, p.load_image.rows
    assert_color [255, 0, 0], '160x120', p
  end
  
  def test_should_delete_an_abstract_model
    p = Abstract.new
    assert p.save
    assert_nothing_raised { p.destroy }
  end
  
end