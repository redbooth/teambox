class ConversationsController < ApplicationController
  def new
    @conversation = @current_project.conversations.new
  end
  
  def create
    @conversation = @current_project.new_conversation(current_user,params[:conversation])
    
    respond_to do |f|
      if @conversation.save
        f.html { redirect_to project_conversation_path(@current_project,@conversation) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  def show
  end
end