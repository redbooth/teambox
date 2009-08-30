require File.dirname(__FILE__) + '/../../test/test_helper'

class ValidatedPhoto < ActiveRecord::Base
  set_table_name :photo_dbs
  acts_as_fleximage
  
  def validate
    # overiding the validate method
  end
end

class FleximageRequireImageOptionTest < Test::Unit::TestCase
  def test_should_require_image_by_default
    p = PhotoBare.new
    assert !p.save, 'Record expected to not be allowed to save'
  end
  
  def test_should_disable_image_requirement
    PhotoBare.require_image = false
    p = PhotoBare.new
    assert p.save, 'Record expected to be allowed to save'
  ensure
    PhotoBare.require_image = true
  end
  
  def test_should_require_image_when_validate_is_overriden
    p = ValidatedPhoto.new
    assert !p.save, 'Record expected to not be allowed to save'
  end
end