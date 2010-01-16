require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it { should have_many(:projects_owned) }
  it { should have_many(:people) }
  it { should have_many(:projects) }
  it { should have_many(:invitations) }
  it { should have_many(:activities) }
  it { should have_many(:uploads) }

  it { should validate_presence_of(:login) }
  it { should validate_length_of(:login, :within => 3..40) }
  it { should validate_uniqueness_of(:login) }

  # TODO: Validates format of login, name and email

  it { should validate_length_of(:first_name, :within => 1..20) }
  it { should validate_length_of(:last_name,  :within => 1..20) }

  it { should validate_presence_of(:email) }
  it { should validate_length_of(:email, :within => 6..100) }
  it { should validate_uniqueness_of(:email) }

# it { should validate_associated :projects }

  describe "invited count" do
    before do
      @project = Factory(:project)
      @user = @project.user
      invitation = Invitation.new(:user => @user, :project => @project, :user_or_email => "invited@user.com")
      invitation.save!
      @new_user = Factory(:user, :email => "invited@user.com")
      @user.reload
    end

    it "should increment invited_count when somebody accepts his invitation" do
      @user.invited_count.should == 1
    end

    it "should have a nil invited_by_id field if he signed up by himself" do
      @user.invited_by.should == nil
    end

    it "should set the invited by field to the person who invited the user" do
      @new_user.invited_by.should == @user
    end
  end

  describe "authentication" do
    before do
      @login = 'dickdivers'
      @email = 'dick@divers.com'
      @password = 'nightingale'
      @user = Factory.create(:user, :login => @login, :email => @email, :password => @password, :password_confirmation => @password)
    end

    it "should return the user object for a valid login using his username" do
      User.authenticate(@login, @password).should == @user
      User.authenticate(@login.upcase, @password).should == @user
    end

    it "should return the user object for a valid login using his email" do
      User.authenticate(@email, @password).should == @user
      User.authenticate(@email.upcase, @password).should == @user
    end

    it "should return nil for incorrect login attempts" do
      User.authenticate(@login, "bad_password").should be_nil
      User.authenticate(@email, "bad_password").should be_nil
      User.authenticate("bad_email", "badpass").should be_nil
      User.authenticate("", "").should be_nil
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
      @user.get_recent_projects.should include(projects.first, projects.second, projects.third)
    end

    it "should properly remove tabs" do
      projects = []
      3.times do
        project = Factory(:project)
        projects << project
        @user.add_recent_project(project)
      end
      @user.remove_recent_project(projects.second)
      @user.get_recent_projects.should include(projects.first, projects.third)
      @user.get_recent_projects.should_not include(projects.second)
    end

    it "shouldn't add dozens of projects to the bar" do
      20.times do
        project = Factory(:project)
        @user.add_recent_project(project)
      end
      @user.get_recent_projects.size.should_not == 20
    end

    describe "the recent projects" do
      before do
        @projects = []
        3.times do
          project = Factory(:project, :user => @user)
          @projects << project
          @user.add_recent_project(project)
        end
      end

      describe "when a project is archived" do
        it "should be removed from the tab" do
          @projects.first.archive!
          @user.get_recent_projects.should include(@projects.second, @projects.third)
          @user.get_recent_projects.should_not include(@projects.first)
        end
      end

      describe "when a project is deleted" do
        it "should be removed from the tab" do
          @projects.first.destroy
          @user.get_recent_projects.should include(@projects.second, @projects.third)
          @user.get_recent_projects.should_not include(@projects.first)
        end
      end
    end

  end

  describe "validation" do
    before do
      @user = Factory.create(:user, :first_name => " holden ", :last_name => "  m. caulfield   ",
                                    :login => "Holden", :email => "HoldeN.Caulfield@pencey.edu")
    end

    it "should capitalize first and last name on create" do
      @user.name.should == "Holden M. Caulfield"
    end

    it "should convert email to downcase and strip spaces" do
      @user.email.should == "holden.caulfield@pencey.edu"
    end

    it "should convert login to downcase and strip spaces" do
      @user.login.should == "holden"
    end

  end

  describe "signup and activation" do
    it "should not accept duplicate logins or tildes" do
      Factory.build(:user, :login => '_j0aquIN').save.should be_true
      Factory.build(:user, :login => '_j0aQUin').save.should be_false
      Factory.build(:user, :login => '_j0a-QUin').save.should be_false
      Factory.build(:user, :login => '_j0aquín').save.should be_false
      Factory.build(:user, :login => '_j0aquin+').save.should be_false
    end

    it "should send an activation email when signing up without an invitation" do
      @user = Factory.build(:user)
      Emailer.should_receive(:deliver_confirm_email).once
      @user.save
    end

    it "should not send an activation email if the user is active when created, for example, when invited" do
      @user = Factory.build(:user, :confirmed_user => true)
      Emailer.should_not_receive(:deliver_confirm_email)
      @user.save
    end

    it "should not be active when first created" do
      user = Factory.create(:user)
      user.is_active?.should be_false
    end
  end

  describe "factories" do
    it "should generate Mislav for use in Cucumber stories" do
      mislav = Factory.create(:mislav)
      mislav.valid?.should be_true
      mislav.projects.should == []
    end
  end

end
