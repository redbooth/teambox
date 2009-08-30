require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageOperatorResizeTest < Test::Unit::TestCase
  def setup
    @photo  = PhotoBare.create(:image_file => files(:photo))
    proxy   = Fleximage::ImageProxy.new(@photo.load_image, @photo)
    @op     = Fleximage::Operator::Base.new(proxy, @photo.load_image, @photo)
    
    @other_img = Magick::Image.read(@photo.file_path).first
  end
  
  def test_should_resize
    @photo.operate { |p| p.resize '300x400' }
    assert_equal 400, @photo.load_image.rows
    assert_equal 300, @photo.load_image.columns
  end
  
end