require 'spec_helper'

describe SessionsController do
  route_matches "/logout", :get, :controller => "sessions", :action => "destroy"
  
  describe "#destroy" do
    before  do
      @user = Factory.create(:confirmed_user)
      login_as @user
    end
    
    it "should clear session" do 
      get :destroy
      session[:user_id].should be_nil
    end

    it "should redirect to goodbye page" do 
      get :destroy
      response.should be_redirect
      response.should redirect_to(goodbye_path)
    end
  end
end
