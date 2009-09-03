require File.dirname(__FILE__) + '/../../test/test_helper'

class FleximageFileUploadFromStringsTest < Test::Unit::TestCase
  def test_should_accept_file_as_string
    data = files(:photo).read
    
    p = PhotoBare.new
    p.image_file_string = data
    p.save
    assert p.save, 'Record expected to be allowed to save'
    assert p.has_image?
  end
  
  def test_should_accept_file_as_base64
    data = Base64.encode64(files(:photo).read)
    
    p = PhotoBare.new
    p.image_file_base64 = data
    p.save
    assert p.save, 'Record expected to be allowed to save'
    assert p.has_image?
  end
end
