require 'spec_helper'

describe ApiV2::ConversationsController do
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

      JSON.parse(response.body).length.should == 2
    end

    # NOTE: There's a middleware (Rack::JSONP) which takes care of it! So don't
    #       look for the code on ApiV2.
   xit "shows conversations with a JSONP callback" do
      login_as @user

      get :index, :project_id => @project.permalink, :callback => 'lolCat'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows conversations in all projects" do
      login_as @user

      conversation = Factory.create(:conversation, :project => Factory.create(:project))
      conversation.project.add_user(@user)

      get :index
      response.should be_success

      JSON.parse(response.body).length.should == 3
    end

    it "shows conversations created by a user" do
      login_as @user

      get :index, :user_id => @owner.id
      response.should be_success

      JSON.parse(response.body).map{ |o| o['id'] }.should == [@conversation.id]
    end

    it "shows no conversations created by a fictious user" do
      login_as @user

      get :index, :user_id => -1
      response.should be_success

      JSON.parse(response.body).length.should == 0
    end

    it "shows threads if specified" do
      login_as @user

      get :index, :project_id => @project.permalink, :type => 'thread'
      response.should be_success

      content = JSON.parse(response.body)
      content.each { |c| c['simple'].should == true }
      content.length.should == 1
    end

    it "shows conversations only if specified" do
      login_as @user

      get :index, :project_id => @project.permalink, :type => 'conversation'
      response.should be_success

      content = JSON.parse(response.body)
      content.length.should == 1
      content.each { |c| c['simple'].should == false }
    end

    it "limits conversations" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body).length.should == 1
    end

    it "limits and offsets conversations" do
      login_as @user

      other_conversation = @project.new_conversation(@user, {:name => 'Something else needs to be done'})
      other_conversation.body = 'Hell yes!'
      other_conversation.save!

      get :index, :project_id => @project.permalink, :since_id => @project.reload.conversation_ids[-1], :count => 1
      response.should be_success

      JSON.parse(response.body).map{ |a| a['id'].to_i }.should == [@project.reload.conversation_ids[0]]
    end

    # NOTE: This is the biggest difference between ApiV1 and ApiV2, we are
    #       returning objects with references, not just the reference ids.
    #
    # TODO: Maybe it's a good idea to copy a full API response and match the test
    #       against it.
    it "returns full linked objects" do
      login_as @user

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      conversation(data.first)
    end

    it "does not show unwatched private conversations in a project" do
      login_as @user
      @conversation.update_attribute(:is_private, true)

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body).length.should == 1
    end
  end

  describe "#show" do
    it "shows a conversation with references" do
      login_as @user

      get :show, :project_id => @project.permalink, :id => @conversation.id
      response.should be_success

      data = JSON.parse(response.body)
      data['id'].to_i.should == @conversation.id

      conversation(data)
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

  def conversation(data)
    data.include?('project').should == true
    data.include?('first_comment').should == true
    data.include?('recent_comments').should == true
    data['recent_comments'].first.include?('body').should == true
    data['recent_comments'].first.include?('project').should == true
  end

end
