require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
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
      assigns[:user].errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  describe "on POST to create with bad params" do
    before do
      post :create, :user => {}
    end

    it "should render the new template" do
      response.should render_template('users/new.haml')
    end

    it "should have errors on the user" do
      assigns[:user].should_not be_nil
    end

    it "should render the new user view" do
      response.should render_template('users/new')
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
  