require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageDefaultImagePathOptionTest < Test::Unit::TestCase
  def test_should_use_a_default_image
    PhotoBare.require_image = false
    PhotoBare.default_image_path = "../fixtures/photo.jpg"
    
    p = PhotoBare.new
    assert p.save
    assert_equal 1024, p.load_image.rows
    assert_equal 768,  p.load_image.columns
  ensure
    PhotoBare.require_image = true
    PhotoBare.default_image_path = nil
  end
end
