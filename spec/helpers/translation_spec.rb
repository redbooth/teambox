require 'spec_helper'

describe 'Translations' do

  before do
    I18n.backend.store_translations :en, :test_number => "Test number %{number}"
    @old_locale = I18n.locale
    I18n.locale=:ca
  end

  after do
    I18n.locale= @old_locale
  end

  it "should fall back to the default locale when the key doesn't exist" do
    I18n.t(:test_number, :number=>1).should == "Test number 1"
  end

  it "should fall back to the default locale when the interpolation doesn't work" do
    I18n.backend.store_translations :ca, :test_number => "Test número %{numero}"
    I18n.t(:test_number, :number=>1).should == "Test number 1"
  end

  it "should translate normally when everything is alright" do
    I18n.backend.store_translations :ca, :test_number => "Test número %{number}"
    I18n.t(:test_number, :number=>1).should == "Test número 1"
  end

end
