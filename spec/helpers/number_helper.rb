require 'spec_helper'

describe 'number helpers with all available locales' do
  describe 'number_with_precision' do
    I18n.available_locales.each do |locale|
      it "should have the locale settings for the #{locale} locale" do
        defaults           = I18n.translate(:'number.format', :locale => locale, :default => {})
        precision_defaults = I18n.translate(:'number.precision.format', :locale => locale, :default => {})
        defaults           = defaults.merge(precision_defaults)
        precision          = defaults.delete :precision
        precision.should_not be_nil
      end

      it "should output the expected result for the #{locale} locale" do
        lambda do
          number_with_precision(11.234, :locale => locale)
        end.should_not raise_error
      end
    end
  end
end

