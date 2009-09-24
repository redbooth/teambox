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
    @comments = Comment.get_comments(current_user,@conversation)
    @conversations = @current_project.conversations
  end
  
  private
    def load_conversation
      @conversation = @current_project.conversations.find(params[:id])
      
      if @conversation.nil?
        redirect_to project_path(@current_project)
      end
    end
end