require 'spec_helper'

describe StaticPagesController do
  route_matches "/goodbye", :get, :controller => "static_pages", :action => "goodbye"
  
  describe "#goodbye" do
    it "should successfully render template" do 
      get :goodbye
      response.should be_success
      response.should render_template('goodbye')
    end
  end
end
