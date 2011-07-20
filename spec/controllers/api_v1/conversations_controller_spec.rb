require 'spec_helper'

describe ApiV1::ConversationsController do
  before do
    make_a_typical_project
    
    @conversation = @project.new_conversation(@owner, {:name => 'Something needs to be done'})
    @conversation.body = 'Hell yes!'
    @conversation.save!
    
    @another_conversation = @project.new_conversation(@user, {:name => 'We need a meeting!'})
    @another_conversation.simple = true
    @another_conversation.body = 'Hell yes!'
    @another_conversation.save!
  end
  
  describe "#index" do
    it "shows conversations in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 2
    end
    
    it "shows conversations with a JSONP callback" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'js'
      response.should be_success
      
      response.body.split('(')[0].should == 'lolCat'
    end
    
    it "shows conversations in all projects" do
      login_as @user
      
      conversation = Factory.create(:conversation, :project => Factory.create(:project))
      conversation.project.add_user(@user)
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 3
    end
    
    it "shows conversations created by a user" do
      login_as @user
      
      get :index, :user_id => @owner.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|o|o['id']}.should == [@conversation.id]
    end
    
    it "shows no conversations created by a fictious user" do
      login_as @user
      
      get :index, :user_id => -1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 0
    end
    
    it "shows threads if specified" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :type => 'thread'
      response.should be_success
      
      content = JSON.parse(response.body)['objects']
      content.each {|c| c['simple'].should == true}
      content.length.should == 1
    end
    
    it "shows conversations only if specified" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :type => 'conversation'
      response.should be_success
      
      content = JSON.parse(response.body)['objects']
      content.length.should == 1
      content.each {|c| c['simple'].should == false}
    end
    
    it "limits conversations" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "limits and offsets conversations" do
      login_as @user
      
      other_conversation = @project.new_conversation(@user, {:name => 'Something else needs to be done'})
      other_conversation.body = 'Hell yes!'
      other_conversation.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.reload.conversation_ids[-1], :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.reload.conversation_ids[0]]
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']
      
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@conversation.user_id}_User").should == true
      references.include?("#{@conversation.first_comment.user_id}_User").should == true
      references.include?("#{@conversation.first_comment.id}_Comment").should == true
      @conversation.recent_comments.each do |comment|
        references.include?("#{comment.id}_Comment").should == true
        references.include?("#{comment.user_id}_User").should == true
      end
    end
  end
  
  describe "#show" do
    it "shows a conversation" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @conversation.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @conversation.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create conversations" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :name => 'Created!', :body => 'Discuss...'
      response.should be_success
      
      @project.conversations(true).length.should == 3
      @project.conversations.first.name.should == 'Created!'
      @project.conversations.first.comments.length.should == 1
    end
    
    it "should not allow observers to create conversations" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :name => 'Created!', :body => 'Discuss...'
      response.status.should == 401
      
      @project.conversations(true).length.should == 2
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a conversation" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @conversation.id, :name => 'Modified'
      response.should be_success
      
      @conversation.reload.name.should == 'Modified'
    end
    
    it "should allow participants to convert a conversation to a task" do
      login_as @user
      
      post :convert_to_task, :project_id => @project.permalink,
                             :id => @another_conversation.id,
                             :conversation => {:name => 'Tasked', :comment => 'Converted!'}
      
      response.should be_success
      data = JSON.parse(response.body)
      data['name'].should == 'Tasked'
      Task.find_by_id(data['id'].to_i).name.should == 'Tasked'
    end
    
    it "should not allow observers to modify a conversation" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :id => @conversation.id, :name => 'Modified'
      response.status.should == 401
      
      @conversation.reload.name.should_not == 'Modified'
    end
  end
  
  describe "#destroy" do
    it "should allow admins to destroy a conversation" do
      login_as @admin
      
      put :destroy, :project_id => @project.permalink, :id => @conversation.id
      response.should be_success
      
      @project.conversations(true).length.should == 1
    end
    
    it "should allow the creator to destroy a conversation" do
      login_as @conversation.user
      
      put :destroy, :project_id => @project.permalink, :id => @conversation.id
      response.should be_success
      
      @project.conversations(true).length.should == 1
    end
    
    it "should not allow participants to destroy a conversation" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :id => @conversation.id
      response.status.should == 401
      
      @project.conversations(true).length.should == 2
    end
  end
end