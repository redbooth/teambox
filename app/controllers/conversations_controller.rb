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
        add_watchers params[:user]
        @conversation.notify_new_comment
        
        f.html { redirect_to project_conversation_path(@current_project,@conversation) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  def index
    if @current_project
      @conversations = @current_project.conversations
    else
      @conversations = []
      current_user.projects.each do |project|
        @conversations |= project.conversations
      end
    end
    
    respond_to do |f|
      f.html
      f.rss { render :layout => false }
    end
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
  
  def destroy
    flash[:success] = t('deleted.conversation', :name => @conversation.name)
    @conversation.destroy
    respond_to do |f|
      f.html { redirect_to project_conversations_path(@current_project) }
    end
  end
  
  private
    def load_conversation
      begin
        @conversation = @current_project.conversations.find(params[:id])
      rescue
        flash[:error] = "Conversation #{params[:id]} not found in this project"
      end
      
      redirect_to project_path(@current_project) unless @conversation
    end
    
    def add_watchers(hash)
      hash.if_defined.each do |user_id, should_notify|
        if should_notify == "1" and Person.exists? :project_id => @conversation.project_id, :user_id => user_id
          user = User.find user_id
          @conversation.add_watcher user# if user
        end
      end
    end
end