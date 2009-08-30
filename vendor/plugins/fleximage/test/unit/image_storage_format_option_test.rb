require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageImageStorageOptionTest < Test::Unit::TestCase
  def test_should_have_default_storage_format_png
    p = PhotoBare.create(:image_file => files(:photo))
    assert_match %r{\d+\.png$}, p.file_path
    assert_equal 'PNG', p.load_image.format
  end
  
  def test_should_set_image_storage_format_to_jpg
    PhotoBare.image_storage_format = :jpg
    p = PhotoBare.create(:image_file => files(:photo))
    assert_match %r{\d+\.jpg$}, p.file_path
    assert_equal 'JPG', p.load_image.format
  ensure
    PhotoBare.image_storage_format = :png
  end
  
  def test_should_have_default_storage_format_png_in_db
    p = PhotoDb.create(:image_file => files(:photo))
    assert_equal 'PNG', p.load_image.format
  end
  
  def test_should_set_image_storage_format_to_jpg_in_db
    PhotoDb.image_storage_format = :jpg
    p = PhotoDb.create(:image_file => files(:photo))
    assert_equal 'JPG', p.load_image.format
  ensure
    PhotoDb.image_storage_format = :png
  end
end