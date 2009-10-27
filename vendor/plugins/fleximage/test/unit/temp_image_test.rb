require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageTempImageTest < Test::Unit::TestCase
  def test_should_save_and_use_a_temp_image
    a1 = Avatar.new(:image_file => files(:photo))
    assert !a1.save
    assert_equal 'photo.jpg', a1.image_file_temp
    assert File.exists?("#{RAILS_ROOT}/tmp/fleximage/#{a1.image_file_temp}")
    
    a2 = Avatar.new(:username => 'Alex Wayne', :image_file_temp => 'photo.jpg')
    
    assert a2.save
    assert File.exists?(a2.file_path)
    assert !File.exists?("#{RAILS_ROOT}/tmp/fleximage/#{a2.image_file_temp}")
  end
end
