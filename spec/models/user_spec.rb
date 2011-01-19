require 'spec_helper'

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
  it { should validate_confirmation_of(:password) }

  # TODO: Validates format of login, name and email

  it { should validate_length_of(:first_name, :within => 1..20) }
  it { should validate_length_of(:last_name,  :within => 1..20) }

  it { should validate_presence_of(:email) }
  it { should validate_length_of(:email, :within => 6..100) }
  it { should validate_uniqueness_of(:email) }

  describe "invited count" do
    before do
      @project = Factory(:project)
      @user = @project.user
      @project.create_invitation(@user, :user_or_email => "invited@user.com")
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
      @user = Factory.create(:unconfirmed_user)
    end

    it "should not be active on creation" do
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
        Emailer.should_receive(:send_with_language).with(:confirm_email, :en, @user.id).once
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
      @user.recent_projects.should be_empty
    end

    it "should add some tabs" do
      projects = []
      3.times do
        project = Factory(:project)
        projects << project
        @user.add_recent_project(project)
      end
      @user.recent_projects.should include(projects.first, projects.second, projects.third)
    end

    it "should properly remove tabs" do
      projects = []
      3.times do
        project = Factory(:project)
        projects << project
        @user.add_recent_project(project)
      end
      @user.recent_projects.should == projects.reverse
      @user.remove_recent_project(projects.second)
      @user.recent_projects.should include(projects.first, projects.third)
      @user.recent_projects.should_not include(projects.second)
    end

    it "shouldn't add dozens of projects to the bar" do
      20.times do
        project = Factory(:project)
        @user.add_recent_project(project)
      end
      @user.recent_projects.size.should_not == 20
    end

    describe "recent projects method" do
      before do
        @projects = []
        @invited = Factory(:user)
        3.times do
          project = Factory(:project, :user => @user)
          project.add_user(@invited)
          @projects << project
          @user.add_recent_project(project)
          @invited.add_recent_project(project)
        end
      end

      it "should return all projects of the user" do
        [@user, @invited].each do |user|
          user.recent_projects.should == @projects.reverse
        end
      end

      describe "when a project is archived" do
        it "it should be removed" do
          project_people = @projects.first.users
          @projects.first.archive!
          project_people.each do |user|
            user.recent_projects.should include(@projects.second, @projects.third)
            user.recent_projects.should_not include(@projects.first)
          end
        end
      end

      describe "when a project is deleted" do
        it "it should be removed" do
          project_people = @projects.first.users
          @projects.first.destroy
          project_people.each do |user|
            user.recent_projects.should include(@projects.second, @projects.third)
            user.recent_projects.should_not include(@projects.first)
          end
        end
      end
    end

  end

  describe "validation" do
    before do
      @user = Factory.create(:user, :first_name => " holden ", :last_name => "  m.  caulfield   ",
                                    :login => "Holden", :email => "HoldeN.Caulfield@pencey.edu")
    end

    it "should strip excess whitespace in first and last names" do
      @user.name.should == "holden m. caulfield"
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
      @user = Factory.build(:unconfirmed_user)
      Emailer.should_receive(:send_with_language).once
      @user.save
    end

    it "should not send an activation email if the user is active when created, for example, when invited" do
      @user = Factory.build(:user, :confirmed_user => true)
      Emailer.should_not_receive(:send_with_language)
      @user.save
    end

    it "should not be active when first created" do
      user = Factory.create(:unconfirmed_user)
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

  describe "when fetching assigned tasks" do
    before do
      @user = Factory(:user)
      @interesting_project = Factory(:project, :user => Factory(:user), :name => "DataMapper")
      @boring_project = Factory(:project, :user => Factory(:user), :name => "Collecting stamps")
      @interesting_project.add_user(@user)
      @boring_project.add_user(@user)
    end

    it "should return all the tasks assigned to a user when called with :all" do
      interesting_task = Factory(:task, :project => @interesting_project)
      boring_task = Factory(:task, :project => @boring_project)
      interesting_task.assign_to(@user)
      boring_task.assign_to(@user)
      user_tasks = @user.assigned_tasks.all
      user_tasks.should include(interesting_task, boring_task)
    end

    it "should not return a held task" do
      held_task = Factory(:held_task, :project => @interesting_project)
      held_task.assign_to(@user)
      @user.assigned_tasks.all.should_not include(held_task)
    end

    it "should not return a resolved task" do
      resolved_task = Factory(:resolved_task, :project => @interesting_project)
      resolved_task.assign_to(@user)
      @user.assigned_tasks.all.should_not include(resolved_task)
    end

    it "should not return a rejected task" do
      rejected_task = Factory(:rejected_task, :project => @interesting_project)
      rejected_task.assign_to(@user)
      @user.assigned_tasks.all.should_not include(rejected_task)
    end
  end

  describe "when fetching the user in a project" do
    before do
      @user = Factory(:user)
      @project = Factory(:project)
      @person = Factory(:person, :project => @project, :user => @user)
      @project.reload
      @user.reload
    end

    it "should return the person the user belongs to in the passed project" do
      @user.in_project(@project).should == @person
    end

    it "should return nil if the user is not part of the project" do
      Factory(:user).in_project(@project).should be_nil
    end
  end

  describe "users for user map" do
    before do
      @org = Factory.create(:organization)
      @admin = Factory.create(:user)
      @org.add_member(@admin, Membership::ROLES[:admin])
      @project = Factory.create(:project)
      @user = Factory.create(:user)
      @org.add_member(@user)
    end
    
    it "should return all users in the organization and its projects" do
      @admin.users_for_user_map.should include(@admin)
      @admin.users_for_user_map.should include(@user)
      @admin.users_for_user_map.should_not include(@project.user)
      
      @admin.users_for_user_map.length.should == 2
      
      @project.user.users_for_user_map.should_not include(@admin)
      @project.user.users_for_user_map.should_not include(@user)
      @project.user.users_for_user_map.should include(@project.user)
      
      @project.user.users_for_user_map.length.should == 1
    end
  end

  describe "in time zone" do
    before do
      @amsterdam_user = Factory(:user, :time_zone => "Amsterdam")
      @budapest_user = Factory(:user, :time_zone => "Budapest")
      @new_york_user = Factory(:user, :time_zone => "Eastern Time (US & Canada)")
      @users_in_tzs = User.in_time_zone(["Amsterdam", "Eastern Time (US & Canada)"])
    end
    it "returns all users in one of the time zones" do
      @users_in_tzs.should include(@amsterdam_user)
      @users_in_tzs.should include(@new_york_user)
    end
    it "does not return a user that's not in one of the time zones" do
      @users_in_tzs.should_not include(@budapest_user)
    end
  end

  describe "deletion" do
    before do
      @user = Factory(:confirmed_user, :login => "simon", :email => "simon@sorcerer.net")
      @user.destroy
    end
    it "renames the login so it can be reused by new signups" do
      @user.login.should == "deleted1__simon"
      @user.email.should == "deleted1__simon@sorcerer.net"
    end
    it "renames the login so it can be reused by new signups" do
      @user2 = Factory(:confirmed_user, :login => "simon", :email => "simon@sorcerer.net")
      @user2.login.should == "simon"
      @user2.email.should == "simon@sorcerer.net"
      @user2.destroy
      @user2.login.should == "deleted2__simon"
      @user2.email.should == "deleted2__simon@sorcerer.net"
    end
    it "has a method to rename the user as the original name" do
      @user = User.find_only_deleted(:first)
      @user.recover!
      @user.rename_as_active
      @user.login.should == "simon"
      @user.email.should == "simon@sorcerer.net"
    end
  end

  describe "finding an available username" do
    it "should return the proposed one if it's free" do
      User.find_available_login("donnie").should == "donnie"
    end

    it "should propose a new one if it's taken" do
      Factory(:user, :login => "rabbit")
      User.find_available_login("rabbit").should == "rabbit2"
    end

    it "should keep looking for a free one until it's possible" do
      Factory(:user, :login => "timetravel")
      Factory(:user, :login => "timetravel2")
      Factory(:user, :login => "timetravel3")
      User.find_available_login("timetravel").should == "timetravel4"
    end

    it "should not take a deleted user's login" do
      that_girl = Factory(:user, :login => "the_girl_who_dies").destroy
      User.find_available_login(that_girl.login).should == "#{that_girl.login}2"
    end
  end
  
  describe "#locale" do
    it "should set a valid locale" do
      user = Factory.create(:user, :locale => 'es')
      user.locale.should == 'es'
    end
    
    it "should fall back to default locale when setting not in list of available locales" do
      user = Factory.create(:user, :locale => 'xy')
      user.locale.should == 'en'
    end

    it "should allow special name formatting for foreign locales" do
      user = Factory :user, :first_name => '保', :last_name => '鎌田'
      I18n.locale = 'ja' # where name is in the format 'last_name first_name さん'
      user.name.should == '鎌田 保 さん'
      I18n.locale = I18n.default_locale # where name is in the format 'first_name last_name'
      user.name.should == '保 鎌田'
    end
  end

  context 'attributes' do
    subject {
      Factory(:user, :card_attributes => { :phone_numbers_attributes => [{:name => '+123456789'}] })
    }
    
    it { should_not be_new_record }
    
    it "should allow setting of work phone number" do
      phone = subject.card.phone_numbers.first
      phone.name == '+123456789'
      phone.get_type.should == 'Work'
    end
  end

  describe "#pending_tasks" do
    before do
      @user = Factory.create(:user)
      @task = Factory.create(:task)
      @task.project.add_user @user
    end
    it "should return empty for a user without tasks" do
      @user.pending_tasks.should be_empty
    end
    it "should list active tasks for the user" do
      @task.assign_to @user
      @user.pending_tasks.should == [@task]
    end
    it "should not list tasks that are not active" do
      [:resolved, :hold, :rejected].each do |status|
        @task.assign_to @user
        @task.status_name = status
        @task.save(:validate => false)
        @user.pending_tasks.should be_empty
      end
    end
    it "should not list tasks from archived projects" do
      @task.assign_to @user
      @task.project.update_attribute :archived, true
      @user.pending_tasks.should be_empty
    end
  end

  describe "#assigned_tasks_count" do
    before do
      @user = Factory.create(:user)
      @participant = Factory.create(:user)
      @task = Factory.create(:task, :status => 0)
      @task.project.add_user @user
    end
    it "should return assigned tasks count" do
      @task.assign_to(@user)

      @user.reload
      @user.assigned_tasks_count.should == 1

      @task.assign_to(@participant)
      @user.reload
      @user.assigned_tasks_count.should == 0
    end
  end


  describe "last visit tracking" do
    before do
      @user = Factory(:user)
    end

    it "should not change when updating the user" do
      lambda { @user.touch }.should_not change(@user, :visited_at)
    end
  end

  describe "profile" do
    before do |variable|
      @user = Factory(:user)
    end

    it "should create a default card on creation" do
      @user.card.should_not be nil
    end
  end
end
