class CommentsController < ApplicationController  
  before_filter :load_comment, :only => [:edit, :update, :show, :destroy]
  
  def create
    if params.has_key?(:project_id)
      @target = set_comment_target(@current_project,params)  
      @comment = @current_project.new_comment(current_user,@target,params[:comment])

      if params[:comment][:status] and Task.status(params[:comment][:status])
        @target.update_attribute(:status, Task.status(params[:comment][:status])) 
        @comment.status = Task.status(params[:comment][:status])
      end    

      @comment.save
      @comment.save_uploads(params)
      current_user.read_comments(@comment,@target)
      @comments = @current_project.comments      
    else
      @user = User.find(params[:user_id])
      @comment = current_user.new_comment(current_user,@user,params[:comment])

      @comment.save      
      @comment.save_uploads(params)
    end  
    
    @original_controller = params[:original_controller]

    respond_to{|f|f.js}
  end

  def show
    respond_to{|f|f.js}
  end

  def edit
    respond_to{|f|f.js}
  end
  
  def update
    @comment.update_attributes(params[:comment])
    @comment.save_uploads(params)
    respond_to{|f|f.js}
  end
  
  def destroy
    @comment.destroy
  end

  private
    def load_comment
      @comment = Comment.find(params[:id])
    end
    

    def set_comment_target(project,params)
      if params[:task_id]
        target = Task.find(params[:task_id])
      elsif params[:task_list_id]
        target = TaskList.find(params[:task_list_id])
      elsif params[:conversation_id]
        target = Conversation.find(params[:conversation_id])
      else      
        target = project
      end    
    end    
end