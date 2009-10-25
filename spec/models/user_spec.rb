require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it { should have_many(:projects_owned) }
  it { should have_many(:people) }
  it { should have_many(:projects) }
  it { should have_many(:invitations) }
  it { should have_many(:activities) }
  it { should have_many(:uploads) }
  it { should have_one(:avatar) }
  
  it { should validate_presence_of     :login }
  it { should validate_length_of       :login,    :within => 3..40 }
  it { should validate_uniqueness_of   :login }
# it { should validate_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message }

# it { should validate_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true }
  it { should validate_length_of       :name,     :maximum => 100 }
                      
  it { should validate_presence_of     :email }
  it { should validate_length_of       :email,    :within => 6..100 }
  it { should validate_uniqueness_of   :email }
# it { should validate_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message }
                      
# it { should validate_associated :projects }
  
  
  describe "authentication" do
    before do
      @login = 'dickdivers'
      @email = 'dick@divers.com'
      @password = 'nightingale'
      @user = Factory.create(:user, :login => @login, :email => @email, :password => @password, :password_confirmation => @password)
    end

    it "should return the user object for a valid login using his username" do
      User.authenticate(@login, @password).should == @user
    end

    it "should return the user object for a valid login using his email" do
      User.authenticate(@email, @password).should == @user
    end

    it "should return nil for incorrect login attempts" do
      User.authenticate(@login, "bad_password").should be_nil
      User.authenticate(@email, "bad_password").should be_nil
      User.authenticate("bad_email", "badpass").should be_nil
    end
  end
  
  describe "activation" do
    before do
      @user = Factory.create(:user)
    end
    
    it "should be active on creation" do
      @user.is_active?.should be_false
    end
    
    it "should generate a different and valid login token each time" do
      @user.generate_login_code!
      lambda { @user.generate_login_code! }.should change(@user, :login_token)
      @user.is_login_token_valid?(@user.login_token).should be_true
    end
    
    it "should expire tokens when asked for" do
      @user.generate_login_code!
      login_token = @user.login_token
      @user.expire_login_code!
      @user.is_login_token_valid?(login_token).should be_false
    end
    
    describe "activation email" do
      it "should send an activation email" do
        Emailer.should_receive(:deliver_confirm_email).with(@user).once
        @user.send_activation_email
      end

      it "should generate a valid login token for the email" do
        @user.send_activation_email
        @user.is_login_token_valid?(@user.login_token).should be_true
      end
    end
  end

  describe "recent projects tabs" do
    before do
      @user = Factory.create(:user)
    end
    
    it "should have an empty array for a new user" do
      @user.get_recent_projects.should be_empty
    end
    
    it "should add some tabs" do
      projects = []
      3.times do
        project = Factory(:project)
        projects << project
        @user.add_recent_project(project)
      end
      @user.get_recent_projects.should include projects.first, projects.second, projects.third
    end

    it "should properly remove tabs" do
      projects = []
      3.times do
        project = Factory(:project)
        projects << project
        @user.add_recent_project(project)
      end
      @user.remove_recent_project(projects.second)
      @user.get_recent_projects.should include projects.first, projects.third
      @user.get_recent_projects.should_not include projects.second
    end
    
    it "shouldn't add dozens of projects to the bar" do
      20.times do
        project = Factory(:project)
        @user.add_recent_project(project)
      end
      @user.get_recent_projects.size.should_not == 20
    end
  end
  
  describe "validation" do
    before do
      @user = Factory.create(:user, :login => "Holden", :email => "HoldeN.Caulfield@pencey.edu")
    end

    it "should convert email to downcase" do
      @user.email.should == @user.email.downcase
    end

    it "should convert login to downcase" do
      @user.login.should == @user.login.downcase
    end
  end
  
  describe "signup and activation" do
    it "should send an activation email on signup" do
      @user = Factory.build(:user)
      Emailer.should_receive(:deliver_confirm_email).once
      @user.save
    end

    it "should not be active when first created" do
      user = Factory.create(:user)
      user.is_active?.should be_false
    end    
  end
end
