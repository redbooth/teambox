require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do

  describe "creating" do 
    before do
      @project = Factory.create(:project)
      @user = @project.user
    end
    
    it "should post a comment to a project" do
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project)
      comment.valid?.should be_true
      comment.save.should be_true
      comment.user.should == @user
      comment.target.should == @project
      @project.comments.last.should == comment
      @user.comments.last.should == comment
    end
  
    describe "formatting" do
      it "should format text" do
        body = "She *used* to _mean_ so much to ME!"
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>She <strong>used</strong> to <em>mean</em> so much to ME!</p>"            
      end
      
      it "should format lists" do
        body = "She used to mean:\n* So\n* much\n* to\n * me!"
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>She used to mean:</p>\n<ul>\n\t<li>So</li>\n\t<li>much</li>\n\t<li>to</li>\n\t<li>me!</li>\n</ul>"
      end
      
      it "should format emails and links" do
        body = 'she@couchsurfing.org used to mean so much to www.teambox.com'
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p><a href=\"mailto:she@couchsurfing.org\">she@couchsurfing.org</a> used to mean so much to <a href=\"http://www.teambox.com\">www.teambox.com</a></p>"
      end
      
      it "should preserve html links and images"
      it "should preserve blocks of code and pre"
    end

    it "should post a comment to a conversation"
    it "should post a comment to a task list"
    it "should post a comment to a task"

    it "should log activities to the project"
    it "should mark comments as read when doing some actions"
  end
end