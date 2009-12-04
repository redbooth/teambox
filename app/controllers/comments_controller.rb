class CommentsController < ApplicationController  
  before_filter :load_comment, :only => [:edit, :update, :show, :destroy]
  before_filter :load_target, :only => [:create]
  before_filter :load_orginal_controller, :only => [:create]  
  
  def create
    if params.has_key?(:project_id)
      @comment  = @current_project.new_comment(current_user,@target,params[:comment])
      @comments = @current_project.comments        
    else
      @comment = current_user.new_comment(current_user,@target,params[:comment])
    end

    if @comment.save
      @comment.save_uploads(params)
      
      if @target.is_a? Task
        @comment.reload
        @task = @comment.target
        @new_comment = @current_project.comments.new
        @new_comment.target = @task
        @new_comment.status = @task.status    
      elsif @target.is_a? TaskList
        @task_list = @comment.target
      elsif @target.is_a? Conversation
        @conversation = @comment.target
      end
    end
    respond_to{|f|f.js}
  end

  def show
    respond_to{|f|f.js}
  end

  def edit
    respond_to{|f|f.js}
  end
  
  def update
    @comment.save_uploads(params) if @comment.update_attributes(params[:comment])
    respond_to{|f|f.js}
  end
  
  def destroy
    @comment.destroy
  end

  private
  
    def load_orginal_controller 
      @original_controller = params[:original_controller]
    end
  
    def load_comment
      @comment = Comment.find(params[:id])
    end
    
    def load_target
      if params.has_key?(:project_id)
        @target = assign_project_target
      else
        @target = User.find(params[:user_id])
      end
    end
    
    def assign_project_target
      if params.has_key?(:task_id)
        t = Task.find(params[:task_id])
        t.status = params[:comment][:status]
        ## ~ AB 
        ## I shouldn't have to assign the assigned person here
        ## In comment.rb it should be accepting the accepts_nested_attributes_for :target
        ## but it won't take it, maybe because its a polymorphic association?
        ## If anyone could fix this it'd be much appreciated
        t.assigned_id = params[:comment][:target_attributes][:assigned_id]
        t
      elsif params.has_key?(:task_list_id)
        TaskList.find(params[:task_list_id])
      elsif params.has_key?(:conversation_id)
        Conversation.find(params[:conversation_id])
      else
        @current_project
      end      
    end
end