require File.dirname(__FILE__) + '/../../test/test_helper'


class BigPhoto < ActiveRecord::Base
  set_table_name :photo_dbs
  acts_as_fleximage do
    validates_image_size '80x60'
  end
end

class WidePhoto < ActiveRecord::Base
  set_table_name :photo_dbs
  acts_as_fleximage do
    validates_image_size '80x0'
  end
end

class HighPhoto < ActiveRecord::Base
  set_table_name :photo_dbs
  acts_as_fleximage do
    validates_image_size '0x60'
  end
end

class MinimumImageSizeTest < Test::Unit::TestCase
  def test_should_not_save_small_image
    p = BigPhoto.new(:image_file => files(:i1x1))
    assert !p.save
    assert p.errors["image_file"].match(/is too small/)
  end
  
  def test_should_save_big_image
    p = BigPhoto.new(:image_file => files(:i100x100))
    assert p.save
  end
  
  def test_should_only_save_wide
    p = WidePhoto.new(:image_file => files(:i1x100))
    assert !p.save
    p = WidePhoto.new(:image_file => files(:i100x1))
    p.save
    assert p.save
  end
  
  def test_should_only_save_high
    p = HighPhoto.new(:image_file => files(:i100x1))
    assert !p.save
    p = HighPhoto.new(:image_file => files(:i1x100))
    assert p.save
  end
  
  def test_should_include_minimum_dimensions_in_message
    p = BigPhoto.new(:image_file => files(:i1x1))
    p.save
    assert_equal "is too small (Minimum: 80x60)", p.errors["image_file"]
  end
end
