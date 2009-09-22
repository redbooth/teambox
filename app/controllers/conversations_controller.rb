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
    @comments = @current_conversation.get_comments(current_user)
    @conversations = @current_project.conversations
  end
  
  def update_comments
    if params.has_key?(:show)
      show = params[:show]
    else
      show = 'all'
    end
    
    @comments = @current_conversation.get_comments(current_user,show)
  end
  
  private
    def load_conversation
      @current_conversation = @current_project.conversations.find(params[:id])
      
      if @current_conversation.nil?
        redirect_to project_path(@current_project)
      end
    end
end