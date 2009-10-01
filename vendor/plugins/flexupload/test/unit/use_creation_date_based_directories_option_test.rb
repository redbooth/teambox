require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageUseCreationDateBasedDirectoriesOptionTest < Test::Unit::TestCase
  def test_should_store_images_with_creation_date_based_directories
    p = PhotoBare.create(:image_file => files(:photo))
    assert_match %r{public/uploads/\d+/\d+/\d+/\d+}, p.file_path
  end
  
  def test_should_store_images_without_creation_date_based_directories
    PhotoBare.use_creation_date_based_directories = false
    p = PhotoBare.create(:image_file => files(:photo))
    assert_no_match %r{public/uploads/\d+/\d+/\d+/\d+}, p.file_path
  ensure
    PhotoBare.use_creation_date_based_directories = true
  end
end