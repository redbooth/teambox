require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  route_matches("/account/settings", :get, :controller => "users", :action => "edit", :sub_action => 'settings')
  route_matches("/account/profile", :get, :controller => "users", :action => "edit", :sub_action => 'profile')
  route_matches("/account/profile", :get, :controller => "users", :action => "edit", :sub_action => 'profile')
  route_matches("/account/notifications", :get, :controller => "users", :action => "edit", :sub_action => 'notifications')
      
  it 'allows signup' do
    lambda do
      do_create
      response.should redirect_to(root_path)
      flash[:success].should_not be_blank
    end.should change(User, :count).by(1)
  end
  
  it 'requires email on signup' do
    lambda do
      do_create(:email => nil)
      assigns[:user].errors_on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  describe "on POST to create with bad params" do
    before do
      post :create, :user => {}
    end

    it "should render the new template" do
      response.should render_template('users/new')
    end

    it "should have errors on the user" do
      assigns[:user].should_not be_nil
    end

    it "should render the new user view" do
      response.should render_template('users/new')
    end
  end
  
  describe "#show" do
    render_views
    
    before do
      @first_project = make_a_typical_project
      @first_user = @user
      @another_first_user = Factory(:confirmed_user, :first_name => 'Frank', :last_name => 'Sinatra')
      @first_project.add_user(@another_first_user)

      @second_project = make_a_typical_project
      @second_user = @user
    end
    
    it "should not show unknown users" do
      login_as @first_user
      get :show, :id => @second_user.id
      response.should_not render_template('users/show')
      response.status.should == 302
    end
    
    it "should show known users" do
      login_as @first_user
      get :show, :id => @first_project.user.id
      response.should render_template('users/show')
    end
    
    it "should show the selected user in the title and not the logged in user" do
      login_as @first_user
      get :show, :id => @another_first_user.id
      response.should have_selector 'title', :content => @another_first_user.name
      response.should_not have_selector 'title', :content => @first_user.name
    end
    
    it "should show projects that you share with this user and not projects that you don't" do
      login_as @first_user
      get :show, :id => @another_first_user.id
      response.should have_selector '.project_link a', :content => @first_project.name
      response.should_not have_selector '.project_link a', :content => @second_project.name
    end
  end

    
  def do_create(options = {})
    post :create, :user => { :email       => 'testing@localhost.com',
                             :login       => 'testing',
                             :first_name  => 'Andrew',
                             :last_name   => 'Wiggin',
                             :password    => 'testing',
                             :password_confirmation => 'testing'}.merge(options)
  end
    
end  
  