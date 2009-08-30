require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageMagicColumnsTest < Test::Unit::TestCase
  def test_should_save_data_in_magic_columns_from_local
    p = PhotoFile.new(:image_file => files(:photo))
    assert_equal 'photo.jpg', p.image_filename
    assert_equal 1024,  p.image_height
    assert_equal 768,   p.image_width
  end
  
  def test_should_save_data_in_magic_columns_from_url
    p = PhotoFile.new(:image_file_url => files(:web_photo))
    assert_equal files(:web_photo), p.image_filename
    assert_equal 110,   p.image_height
    assert_equal 276,   p.image_width
  rescue SocketError
    print '!'
  end
  
  def test_should_delete_magic_columns_when_image_is_deleted
    p = PhotoFile.new(:image_file => files(:photo))
    p.save
    
    p = PhotoFile.find(p.id)
    p.delete_image_file.save
    
    assert_nil p.image_width
    assert_nil p.image_height
  end
end
