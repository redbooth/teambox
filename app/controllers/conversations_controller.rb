class ConversationsController < ApplicationController
  before_filter :load_conversation, :only => [:show,:edit,:update,:destroy,:update_comments,:watch,:unwatch]
  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy]  
  def new
    @conversation = @current_project.conversations.new
  end
  
  def create
    @conversation = @current_project.new_conversation(current_user,params[:conversation])
    @conversation.body = params[:conversation][:body]

    respond_to do |f|
      if @conversation.save
        add_watchers params[:user]
        @conversation.notify_new_comment(@conversation.comments.first)
        
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

#   Use this snippet to test the notification emails that we send:
#    @project = @current_project
#    render :file => 'emailer/notify_conversation', :layout => false
  end

  def update
    @conversation.update_attributes(params[:conversation])
    respond_to{|f|f.js}
  end
  
  def destroy
    if @conversation.editable?(current_user)
      @conversation.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.conversation', :name => @conversation.to_s)
          redirect_to project_conversations_path(@current_project)
        end
        f.js
      end
    else
      respond_to do |f|
        flash[:error] = "You are not allowed to do that!"
        f.html { redirect_to project_conversations_path(@current_project) }
      end
    end
  end
  
  def watch
    @conversation.add_watcher(current_user)
    respond_to{|f|f.js}
  end
  
  def unwatch
    @conversation.remove_watcher(current_user)
    respond_to{|f|f.js}
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