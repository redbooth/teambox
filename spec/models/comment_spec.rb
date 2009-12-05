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
      
      it "should turn to links textile links" do
        body = 'I loved that quote: "I like the Divers, but they want me want to go to a war":http://www.shmoop.com/tender-is-the-night/tommy-barban.html. Great page, too.'
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>I loved that quote: <a href=\"http://www.shmoop.com/tender-is-the-night/tommy-barban.html\">I like the Divers, but they want me want to go to a war</a>. Great page, too.</p>"
      end
      
      it "should add http:// in front of links to www.site.com" do
        body = "I'd link my competitors' \"mistakes\":www.failblog.org, but that'd give them free traffic. So instead I link www.google.com."
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>I&#8217;d link my competitors&#8217; <a href=\"http://www.failblog.org\">mistakes</a>, but that&#8217;d give them free traffic. So instead I link <a href=\"http://www.google.com\">www.google.com</a>.</p>"
      end

      it "should preserve html links and images" do
        body = 'Did you know the logo from Teambox has <a href="http://en.wikipedia.org/wiki/Color_theory">carefully selected colors</a>? <img src="http://app.teambox.com/images/header_logo_large.jpg"/>'
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>Did you know the logo from Teambox has <a href=\"http://en.wikipedia.org/wiki/Color_theory\">carefully selected colors</a>? <img src=\"http://app.teambox.com/images/header_logo_large.jpg\" /></p>"
      end
      
      it "should preserve blocks of code and pre"
      
      it "should link to users page when mentioning @existing_username" do
        user = Factory(:user, :login => 'existing_username')
        User.find_by_login('existing_username').should_not be_nil
        body = "Hey, @existing_username, take a look at this!"
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>Hey, @<a href=\"/users/#{user.id}\">existing_username</a>, take a look at this!</p>"
      end
      
      it "should not link to users page when typing @unexisting_username" do
        body = "Hey, @unexisting_username, take a look at this!"
        comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
        comment.body_html.should == "<p>Hey, @unexisting_username, take a look at this!</p>"
      end
    end

    it "should post a comment to a conversation"
    it "should post a comment to a task list"
    it "should post a comment to a task"

    it "should log activities to the project"
    it "should mark comments as read when doing some actions"
  end
end