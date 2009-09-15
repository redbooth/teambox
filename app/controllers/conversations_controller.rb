class ConversationsController < ApplicationController
  before_filter :load_conversation, :only => [ :show, :edit, :update, :destroy ]
  
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
    @comments = @current_conversation.comments
    @conversations = @current_project.conversations
  end
  
  private
    def load_conversation
      @current_conversation = @current_project.conversations.find(params[:id])
      
      if @current_conversation.nil?
        redirect_to project_path(@current_project)
      end
    end
end