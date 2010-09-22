require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project)
    @project.add_user @user
  end

  describe "#create" do
    it "should set the current user as the author" do
      @jordi = Factory.create(:confirmed_user, :login => 'jordi')
      conversation = Factory(:conversation, :user => @jordi, :project => @project)
      Comment.last.user.should == @jordi

      login_as @user
      xhr :post, :create,
           :project_id => @project.permalink,
           :conversation_id => conversation.id,
           :comment => { :body => "Ieee" }

      Comment.last.user.should == @user
    end
  end
end
