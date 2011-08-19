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

    it "shows conversations as JSON when requested with :text format" do
      login_as @user

      get :index, :project_id => @project.permalink, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil

      JSON.parse(response.body)['objects'].length.should == 2
    end

    it "shows conversations in all projects" do
      login_as @user

      conversation = Factory.create(:conversation, :project => Factory.create(:project))
      conversation.project.add_user(@user)

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 3
    end

    it "shows no conversations for archived projects" do
      login_as @user
      @project.update_attribute :archived, true

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
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

    it "does not show unwatched private conversations in a project" do
      login_as @user
      @conversation.update_attribute(:is_private, true)

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end
  end

  describe "#show" do
    it "shows a conversation with references" do
      login_as @user

      get :show, :project_id => @project.permalink, :id => @conversation.id
      response.should be_success

      data = JSON.parse(response.body)
      data['id'].to_i.should == @conversation.id

      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@conversation.user_id}_User").should == true
      references.include?("#{@conversation.first_comment.user_id}_User").should == true
      references.include?("#{@conversation.first_comment.id}_Comment").should == true
      @conversation.recent_comments.each do |comment|
        references.include?("#{comment.id}_Comment").should == true
        references.include?("#{comment.user_id}_User").should == true
      end
    end

    it "does not show private conversations unwatched by the user" do
      login_as @user
      @conversation.update_attribute(:is_private, true)

      get :show, :project_id => @project.permalink, :id => @conversation.id
      response.status.should == 401
    end

    it "shows private conversations watched by the user" do
      login_as @user
      @conversation.add_watcher(@user)
      @conversation.update_attribute(:is_private, true)

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
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      conversation = Conversation.find_by_id(data['id'])
      conversation.should_not == nil
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{conversation.user_id}_User").should == true
      references.include?("#{conversation.comments.first.id}_Comment").should == true

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
                             :name => 'Tasked', :comment => {:body => 'Converted!'},
                             :status => 2, :assigned_id => @project.people.first.id

      response.should be_success
      data = JSON.parse(response.body)
      data['name'].should == 'Tasked'
      data['assigned_id'].should == @project.people.first.id
      data['status'].should == 2
      Task.find_by_id(data['id'].to_i).name.should == 'Tasked'
    end

    it "should not allow observers to modify a conversation" do
      login_as @observer

      put :update, :project_id => @project.permalink, :id => @conversation.id, :name => 'Modified'
      response.status.should == 401

      @conversation.reload.name.should_not == 'Modified'
    end

    it "should not allow hacking the comment author" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @conversation.id, :name => 'Modified',
          :comments_attributes => { 0 => { :body => 'modified....'}}, :user_id => @observer.id

      response.should be_success

      @conversation.reload.comments.size.should == 2
      comment = @conversation.reload.recent_comments.detect {|c| c.body == 'modified....'}
      comment.should_not be_nil
      comment.user.id.should == @user.id
    end

    it "should not allow participants not watching to modify a private conversation" do
      @conversation.update_attribute(:is_private, true)
      login_as @user

      put :update, :project_id => @project.permalink, :id => @conversation.id, :name => 'Modified'
      response.status.should == 401
    end

    it "should return updated conversation and any references" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @conversation.id,
          :name => 'Modified',
          :comments_attributes => { 0 => { :body => 'modified....',
                                           :uploads_attributes => { 
                                             0 => { 
                                               :asset => mock_uploader("templates.txt", 'text/plain', "jade")
                                             }
                                           }
                                         }
                                   }

      response.should be_success

      data = JSON.parse(response.body)
      objects = data
      objects.should_not be_empty
      last_comment_id = @conversation.recent_comments(true).detect {|c| c.body.include?('modified')}.id
      objects['recent_comment_ids'].should include(last_comment_id)

      references = data['references']
      references.should_not be_empty
      references.map{|r| "#{r['id'].to_s}_#{r['type']}"}.include?("#{last_comment_id}_Comment")
      comment = references.detect {|c| c['type'] == 'Comment' && c['id'] == last_comment_id}
      comment.key?('uploads').should be_true
      comment['uploads'].should_not be_empty
      comment['uploads'].first['download'].include?('templates.txt').should be_true
      comment['uploads'].first['mime_type'].should == 'text/plain'
      comment['uploads'].first['filename'].should == 'templates.txt'
    end
  end

  describe "#watch" do
    it "should not allow participants to watch private conversations" do
      @conversation.update_attribute(:is_private, true)
      login_as @user

      put :watch, :project_id => @project.permalink, :id => @conversation.id
      response.status.should == 401
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

    it "should not allow admins not watching to destroy a private conversation" do
      @conversation.update_attribute(:is_private, true)
      login_as @admin

      put :destroy, :project_id => @project.permalink, :id => @conversation.id
      response.status.should == 401
    end
  end
end
