class CommentsController < ApplicationController  
  before_filter :load_comment, :only => [:edit, :update, :show, :destroy]
  before_filter :load_target, :only => [:create]
  before_filter :load_orginal_controller, :only => [:create]  
  before_filter :set_page_title

  def create
    if params.has_key?(:project_id)
      @comment  = @current_project.new_comment(current_user,@target,params[:comment])
      @comments = @current_project.comments        
    else
      @comment = current_user.new_comment(current_user,@target,params[:comment])
    end

    if @comment.save
      @comment.save_uploads(params)
      
      case @target
      when Conversation
        @conversation = @comment.target
      when TaskList
        @task_list = @comment.target
      when Task
        @comment.reload
        @task = @comment.target
        @task_list = @task.task_list
        @new_comment = @current_project.comments.new
        @new_comment.target = @task
        @new_comment.status = @task.status
      end
    end
    respond_to do |f|
      case @target
      when Project
        f.html { redirect_to project_path(@target) }
        f.m    { redirect_to project_path(@target) }
      else
        f.html { redirect_to @target.project, @target }
        f.m    { redirect_to @target.project, @target }
      end
      f.js
    end
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
  
  def preview
    if params.has_key?(:project_id)
      @comment  = @current_project.new_comment(current_user,@target,params[:comment])     
    else
      @comment = current_user.new_comment(current_user,@target,params[:comment])
    end
    
    @comment.send(:format_attributes)
    render :text => @comment.body_html
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
        t.previous_status = t.status
        t.previous_assigned_id = t.assigned_id
        t.status = params[:comment][:status]
        unless params[:comment][:target_attributes].nil?
          t.assigned_id = params[:comment][:target_attributes][:assigned_id]
        end
        #if t.archived? && [Task::STATUSES[:new],Task::STATUSES[:open],Task::STATUSES[:hold]].include?(t.status)
        #  t.archived = false 
        # end
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