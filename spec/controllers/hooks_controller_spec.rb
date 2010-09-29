require File.dirname(__FILE__) + '/../spec_helper'

describe HooksController do
  before do
    @user = Factory(:user, :email => 'jordi@teambox.com')
    @project = Factory(:project, :user => @user)
    @task = Factory(:task, :project => @project)
    @conversation = Factory(:conversation, :project => @project)
  end

  it "should route hooks/hook_name" do
    route_for(:controller => 'hooks', :action => 'create', :hook_name => 'email', :method => :post).should == "/hooks/email"
  end

  describe "#create" do
    describe "emails" do

      it "should parse incoming emails to new conversation" do
        post_email_hook  @project.permalink,
                                'Random latin text',
                                'Lorem ipsum dolor sit amet, ...',
                                false

        response.should be_success
        conversation = @project.conversations.last(:order => 'id asc')
        conversation.name.should == 'Random latin text'
        conversation.comments.last.body.should == 'Lorem ipsum dolor sit amet, ...'
        conversation.comments.last.uploads.count.should == 0
      end

      it "should parse incoming emails with attachments to new conversation" do
        post_email_hook  @project.permalink,
                                'Hey, check this awesome file!',
                                'Lorem ipsum dolor sit amet, ...'

        response.should be_success
        conversation = @project.conversations.last(:order => 'id asc')
        conversation.name.should == 'Hey, check this awesome file!'
        conversation.comments.last.body.should == 'Lorem ipsum dolor sit amet, ...'
        conversation.comments.last.uploads.count.should == 2
        conversation.comments.last.uploads.first(:order => 'id asc').asset_file_name.should == 'tb-space.jpg'
      end

      it "should parse incoming emails with attachments to conversation answers" do
        post_email_hook "#{@project.permalink}+task+#{@task.id}",
                        '',
                        'I would say something about this task'

        comment = @task.comments(true).last
        comment.body.should == 'I would say something about this task'
        comment.uploads.count.should == 2
      end

      it "should parse incoming emails with attachments to task answers" do
        post_email_hook "#{@project.permalink}+conversation+#{@conversation.id}",
                        '',
                        'I would say something about this conversation'

        comment = @conversation.comments(true).last(:order => 'id asc')
        comment.body.should == 'I would say something about this conversation'
        comment.uploads.count.should == 2
      end

      def post_email_hook(to, subject, body, attachments = true)
        post :create,
             :hook_name => 'email',
             :method => :post,
             :from => 'jordi@teambox.com',
             :to => "#{to}@#{Teambox.config.smtp_settings[:domain]}",
             :text => body,
             :subject => subject,
             :attachments => attachments ? '2' : nil,
             :attachment1 => upload_file("#{Rails.root}/spec/fixtures/tb-space.jpg", 'image/jpg'),
             :attachment2 => upload_file("#{Rails.root}/spec/fixtures/users.yml", 'text/plain')
      end
    end
  end
end
