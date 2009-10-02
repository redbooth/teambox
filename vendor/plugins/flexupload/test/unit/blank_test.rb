require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageBlankTest < Test::Unit::TestCase
  
  def test_should_create_blank_image_of_proper_dimensions
    p = Fleximage::Blank.new('320x480')
    p.operate do |image|
      assert_equal(320, image.width)
      assert_equal(480, image.height)
    end
  end
  
  def test_should_be_transparent_by_default
    p = Fleximage::Blank.new('320x480')
    assert_color([0, 0, 0, 255], '50x50', p)
  end
  
  def test_should_color_image
    p = Fleximage::Blank.new('320x480', :color => 'red')
    assert_color([255, 0, 0, 0], '50x50', p)
  end
  
end