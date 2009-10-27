require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageImageProxyTest < Test::Unit::TestCase
  def test_should_have_a_width
    p = PhotoBare.create(:image_file => files(:photo))
    p.operate do |image|
      assert_equal 768, image.width
    end
  end
  
  def test_should_have_a_height
    p = PhotoBare.create(:image_file => files(:photo))
    p.operate do |image|
      assert_equal 1024, image.height
    end
  end
end