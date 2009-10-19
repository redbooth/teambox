class ConversationsController < ApplicationController
  before_filter :load_conversation, :only => [ :show, :edit, :update, :destroy, :update_comments ]
  
  def new
    @conversation = @current_project.conversations.new
  end
  
  def create
    @conversation = @current_project.new_conversation(current_user,params[:conversation])
    @conversation.body = params[:conversation][:body]

    respond_to do |f|
      if @conversation.save
        f.html { redirect_to project_conversation_path(@current_project,@conversation) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  def index
    @conversations = @current_project.conversations
  end
  
  def show
    @comments = @conversation.comments
    @conversations = @current_project.conversations

    respond_to{|f|f.html}

    ensure CommentRead.user(current_user).read_up_to(@comments.first)

#   Use this snippet to test the notification emails that we send:
#    @project = @current_project
#    render :file => 'emailer/notify_conversation', :layout => false
  end
  
  private
    def load_conversation
      begin
        @conversation = @current_project.conversations.find(params[:id])
      rescue
        flash[:error] = "Conversation #{params[:id]} not found in this project"
      end
      
      if @conversation.nil?
        redirect_to project_path(@current_project)
      end
    end
end