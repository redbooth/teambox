require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximagePreprocessImageOptionTest < Test::Unit::TestCase
  def test_should_resize_image_on_upload
    PhotoDb.preprocess_image do |image|
      image.resize '50x50', :crop => true
    end
    
    p = PhotoDb.new(:image_file => files(:photo))
    assert p.save, 'Record expected to be allowed to save'
    
    assert_equal 50, p.load_image.columns
    assert_equal 50, p.load_image.rows
    
    assert_equal 50, p.image_height
    assert_equal 50, p.image_width
    
  ensure
    PhotoDb.preprocess_image_operation = nil
  end
end
