require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageOperatorBaseTest < Test::Unit::TestCase
  def setup
    @photo  = PhotoBare.create(:image_file => files(:photo))
    proxy   = Fleximage::ImageProxy.new(@photo.load_image, @photo)
    @op     = Fleximage::Operator::Base.new(proxy, @photo.load_image, @photo)
    
    @other_img = Magick::Image.read(@photo.file_path).first
  end
  
  def test_should_raise_operation_not_implemented_exception
    assert_raise(Fleximage::Operator::OperationNotImplemented) do
      @photo.operate { |p| p.base }
    end
  end
  
  
  # size_to_xy
  
  def test_should_parse_size_string_to_x_and_y
    assert_equal [1,2],     @op.size_to_xy('1x2')
    assert_equal [640,480], @op.size_to_xy('640x480')
  end
  
  def test_should_parse_size_array_to_x_and_y
    assert_equal [1,2],     @op.size_to_xy([1,2])
    assert_equal [640,480], @op.size_to_xy([640,480])
  end
  
  def test_should_parse_single_size_array_to_square_x_and_y
    assert_equal [2,2],     @op.size_to_xy(2)
    assert_equal [2,2],     @op.size_to_xy('2')
    assert_equal [480,480], @op.size_to_xy(480)
    assert_equal [480,480], @op.size_to_xy('480')
  end
  
  
  # scale
  
  def test_should_scale_the_main_image_and_keep_its_aspect_ratio
    img = @op.scale(400)
    assert_equal 400, img.rows
    assert_equal 300, img.columns
    assert_equal 400, @photo.load_image.rows
    assert_equal 300, @photo.load_image.columns
  end
  
  def test_should_scale_a_different_image_and_keep_its_aspect_ratio
    @op.scale(400, @other_img)
    assert_equal 400, @other_img.rows
    assert_equal 300, @other_img.columns
    assert_equal 1024, @photo.load_image.rows
    assert_equal 768, @photo.load_image.columns
  end
  
  
  # scale and crop
  
  def test_should_scale_and_crop_the_main_image
    img = @op.scale_and_crop(400)
    assert_equal 400, img.rows
    assert_equal 400, img.columns
    assert_equal 400, @photo.load_image.rows
    assert_equal 400, @photo.load_image.columns
  end
  
  def test_should_scale_and_crop_a_different_image
    @op.scale_and_crop(400, @other_img)
    assert_equal 400, @other_img.rows
    assert_equal 400, @other_img.columns
    assert_equal 1024, @photo.load_image.rows
    assert_equal 768, @photo.load_image.columns
  end
  
  
  # stretch
  
  def test_should_stretch_the_main_image
    img = @op.stretch(400)
    assert_equal 400, img.rows
    assert_equal 400, img.columns
    assert_equal 400, @photo.load_image.rows
    assert_equal 400, @photo.load_image.columns
  end
  
  def test_should_stretch_a_different_image
    @op.stretch(400, @other_img)
    assert_equal 400, @other_img.rows
    assert_equal 400, @other_img.columns
    assert_equal 1024, @photo.load_image.rows
    assert_equal 768, @photo.load_image.columns
  end
  
  
  def test_should_convert_symbol_to_rmagick_blending_mode
    assert_equal Magick::MultiplyCompositeOp,   @op.symbol_to_blending_mode(:multiply)
    assert_equal Magick::OverCompositeOp,       @op.symbol_to_blending_mode(:over)
    assert_equal Magick::ScreenCompositeOp,     @op.symbol_to_blending_mode(:screen)
    assert_equal Magick::CopyBlackCompositeOp,  @op.symbol_to_blending_mode(:copy_black)
  end
  
  def test_should_raise_argument_error_when_no_blend_mode_found
    assert_raise(ArgumentError) do
      @op.symbol_to_blending_mode(:foobar)
    end
  end
  
  
  # gravity lookup
  
  def test_should_lookup_correct_gravity
    assert_equal Magick::CenterGravity,     @op.symbol_to_gravity(:center)
    assert_equal Magick::NorthGravity,      @op.symbol_to_gravity(:top)
    assert_equal Magick::SouthWestGravity,  @op.symbol_to_gravity(:bottom_left)
  end
  
  def test_should_raise_error_with_a_bad_gravity
    assert_raise(ArgumentError) do
      @op.symbol_to_gravity(:foo)
    end
  end
  
end
