require File.dirname(__FILE__) + '/../../test/test_helper'


class I18nMessagesTest < Test::Unit::TestCase
  def test_should_have_default_message
    p = PhotoBare.new
    p.save
    assert_equal "is required", p.errors["image_file"]
    p = PhotoBare.new(:image_file => files(:not_a_photo))
    p.save
    assert_equal "was not a readable image", p.errors["image_file"]
    p = PhotoBare.new(:image_file => files(:i1x1))
    p.save
    assert_equal "is too small (Minimum: 2x2)", p.errors["image_file"]
  end
  
  def test_should_have_german_message
    I18n.locale = "de"
    p = PhotoBare.new
    p.save
    assert_equal "ist erforderlich", p.errors["image_file"]
    p = PhotoBare.new(:image_file => files(:not_a_photo))
    p.save
    assert_equal "war nicht lesbar", p.errors["image_file"]
    p = PhotoBare.new(:image_file => files(:i1x1))
    p.save
    assert_equal "ist zu klein (Minimalgröße: 2x2)", p.errors["image_file"]
  ensure
    I18n.locale = "en"
  end
  
  def test_should_have_model_specific_message
    p = PhotoCustomError.new
    p.save
    assert_equal "needs to be attached", p.errors["image_file"]
    p = PhotoCustomError.new(:image_file => files(:not_a_photo))
    p.save
    assert_equal "seems to be broken", p.errors["image_file"]
    p = PhotoCustomError.new(:image_file => files(:i1x1))
    p.save
    assert_equal "must be bigger (min. size: 2x2)", p.errors["image_file"]
  end
end
