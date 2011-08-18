require 'spec_helper'

describe ProjectsController do
  render_views
  
  describe "#index" do
    before do
      @user = Factory(:confirmed_user)
      @project = Factory(:project)
      @project.add_user @user
    end
    
    it "should show a project when using mobile views" do
      login_as @user
      
      get :index, :format => 'm'
      
      response.should render_template('projects/index')
      response.body.match(/Use full Teambox/).should_not == nil
    end
    
    it "should not shown private objects we cant see in feeds" do
      login_as @user
      
      conversation = Factory.create(:conversation, :project => @project, :name => 'We screwed up', :body => 'PANIC!', :is_private => true)
      task = Factory.create(:task, :project => @project, :name => 'Silence the critics', :comments_attributes => {'0' => {'body' => 'People are asking too many questions'} }, :is_private => true)
      other_conversation = Factory.create(:conversation, :project => @project, :name => 'We deny everything', :body => 'Nothing wrong here')
      
      get :index, :format => 'rss'
      response.body.match(/We screwed up/).should == nil
      response.body.match(/PANIC!/).should == nil
      response.body.match(/Silence the critics/).should == nil
      response.body.match(/People are asking too many questions/).should == nil
      response.body.match(/We deny everything/).should_not == nil
      response.body.match(/Nothing wrong here/).should_not == nil
    end
    
    it "should not shown private objects we cant see in ical" do
      login_as @user
      
      task = Factory.create(:task, :project => @project, :name => 'Silence the critics', :comments_attributes => {'0' => {'body' => 'People are asking too many questions'} }, :is_private => true, :due_on => Time.now)
      other_task = Factory.create(:task, :project => @project, :name => 'Fix everything', :due_on => Time.now)
      
      get :show, :id => @project.id, :format => 'ics'
      
      response.body.match(/Fix everything/).should_not == nil
      response.body.match(/Silence the critics/).should == nil
      response.body.match(/People are asking too many questions/).should == nil
    end
  end
  
  describe "#show" do
    before do
      @user = Factory(:confirmed_user)
      @project = Factory(:project)
      @project.add_user @user
      
      @task = Factory.create(:task, :project => @project, :name => 'Silence the critics', :comments_attributes => {'0' => {'body' => 'People are asking too many questions'} }, :is_private => true, :due_on => Time.now)
    end
    
    it "should not show private objects we cant see in feeds" do
      login_as @user
      
      conversation = Factory.create(:conversation, :project => @project, :name => 'We screwed up', :body => 'PANIC!', :is_private => true)
      other_conversation = Factory.create(:conversation, :project => @project, :name => 'We deny everything', :body => 'Nothing wrong here')
      
      get :show, :id => @project.id, :format => 'rss'
      response.body.match(/We screwed up/).should == nil
      response.body.match(/PANIC!/).should == nil
      response.body.match(/Silence the critics/).should == nil
      response.body.match(/People are asking too many questions/).should == nil
      response.body.match(/We deny everything/).should_not == nil
      response.body.match(/Nothing wrong here/).should_not == nil
    end
    
    it "should not show private objects we cant see in ical" do
      login_as @user
      
      other_task = Factory.create(:task, :project => @project, :name => 'Fix everything', :due_on => Time.now)
      
      get :show, :id => @project.id, :format => 'ics'
      
      response.body.match(/Fix everything/).should_not == nil
      response.body.match(/Silence the critics/).should == nil
      response.body.match(/People are asking too many questions/).should == nil
    end
  end
  
  describe "#create" do
    it "creates a project with invitations" do
      login_as(:confirmed_user)
    
      @user2 = Factory.create(:user)
    
      project_attributes = Factory.attributes_for(:project,
        :organization_id => Factory(:organization).id
      )

      invite_attributes = Factory.attributes_for(:project,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni"
      )

      lambda {
        post :create, :project => project_attributes
        response.should be_redirect
      }.should change(Project, :count)
    end

    it "creates invitations for newly created project" do
      login_as(:confirmed_user)

      @user2 = Factory.create(:user)

      project_attributes = Factory.attributes_for(:project,
        :organization_id => Factory(:organization).id
      )

      invite_attributes = Factory.attributes_for(:project,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni"
      )

      post :create, :project => project_attributes
      response.should be_redirect
      project = Project.last(:order => 'id')

      post :send_invites, :project_id => project.id, :project => invite_attributes
      response.should be_redirect
      project.invitations.with_deleted.count.should == 2
    end

  end
  
  describe "#create" do
    it "creates a project with an existing organization" do
      @user = Factory.create(:confirmed_user)
      login_as @user
    
      @user2 = Factory.create(:user)
      @org = Factory.create(:organization)
      @org.add_member(@user, Membership::ROLES[:admin])
    
      project_attributes = Factory.attributes_for(:project,
        :organization_id => @org.id
      )

      invite_attributes = Factory.attributes_for(:project,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni"
      )

      lambda {
        post :create, :project => project_attributes
        response.should be_redirect
      }.should change(Project, :count)

      project = Project.last(:order => 'id')

      post :send_invites, :project_id => project.id, :project => invite_attributes
      response.should be_redirect

      project.invitations.with_deleted.count.should == 2
    end
  end
  
  describe "#join" do
    it "should let admins from the projects organization add themselves" do
      @project = Factory.create(:project)
      @user = Factory.create(:confirmed_user)
      @project.organization.add_member(@user, Membership::ROLES[:admin])
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@project.user_id).should == true
    end
    
    it "should let people add themselves to public projects as commenters" do
      @project = Factory.create(:project)
      @project.update_attribute(:public, true)
      @user = Factory.create(:confirmed_user)
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@user.id).should == true
    end
    
    it "should not allow people to add themselves to non-public projects" do
      @project = Factory.create(:project)
      @user = Factory.create(:confirmed_user)
      
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should_not change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@user.id).should == false
    end
  end
end
