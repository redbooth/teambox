require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageImageDirectoryOptionTest < Test::Unit::TestCase
  def test_should_store_in_default_image_directory
    p = PhotoBare.create(:image_file => files(:photo))
    assert_match %r{public/uploads/\d+/\d+/\d+/\d+}, p.file_path
    assert File.exists?(p.file_path)
  end
  
  def test_should_set_image_directory
    PhotoBare.image_directory = 'public/uploads/foo'
    p = PhotoBare.create(:image_file => files(:photo))
    assert_match %r{public/uploads/foo/\d+/\d+/\d+/\d+}, p.file_path
    assert File.exists?(p.file_path)
  ensure
    PhotoBare.image_directory = 'public/uploads'
  end
end