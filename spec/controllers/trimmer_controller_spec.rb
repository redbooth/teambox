require 'spec_helper'

describe TrimmerController do

  describe "#resources" do
    I18n.available_locales.each do |locale|
      it "returns a javascript non-empty file" do
        get :resources, :locale => locale
        response.should be_success
        response.should_not be_empty
      end
    end
  end
end
