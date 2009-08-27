class CommentsController < ApplicationController
  before_filter :load_target
  
  def create
    if !params[:task_id].nil?
      # Commenting on a task
      target = Task.find(params[:task_id])
    elsif !params[:task_list_id].nil?
      # Commenting on a task list
      target = TaskList.find(params[:task_list_id])
    elsif !params[:conversation_id].nil?
      # Commenting on a conversation
      target = Conversation.find(params[:conversation_id])
    else
      # Commenting on a project
      target = @current_project
    end

    @comment = @current_project.new_comment(current_user,target,params[:comment])
    @comment.save
    
    respond_to{|f|f.js}
  end
  
  private
    def load_target
      
    end
end