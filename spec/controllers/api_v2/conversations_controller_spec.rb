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
    it "shows conversations in all projects" do
      login_as @user

      get :index
      response.should be_success

      data = JSON.parse(response.body)
      data.length.should == 2

      assigns[:context].should be_a_kind_of(User)
    end

    it "shows conversations in a project" do
      login_as @user

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      data.length.should == 2

      assigns[:context].should be_a_kind_of(Project)
    end

  end

  describe "#show" do

    it "returns a nice 404 message from the API when not found" do
      login_as @user

      # TODO: Replace this by Rspec
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => 'unexisting'
      end
    end

    it "shows a conversation" do
      login_as @user

      get :show, :id => @conversation
      response.should be_success
    end

  end

end
