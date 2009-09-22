class CommentsController < ApplicationController  
  before_filter :load_comment, :only => [:edit,:update,:show,:destroy]
  
  def create
    if !params[:task_id].nil?
      target = Task.find(params[:task_id])
    elsif !params[:task_list_id].nil?
      target = TaskList.find(params[:task_list_id])
    elsif !params[:conversation_id].nil?
      target = Conversation.find(params[:conversation_id])
    else      
      target = @current_project
    end

    was_target_read = CommentRead.user(current_user).are_comments_read?(target)

    @comment = @current_project.new_comment(current_user,target,params[:comment])
    @comment.save

    save_uploads(@comment)
    
    if was_target_read
      CommentRead.user(current_user).read_up_to(@comment)
    end

    @original_controller = params[:original_controller]
    @current_date = Time.current
    set_year_month(@current_date.year,@current_date.month)

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
    save_uploads(@comment)
    respond_to{|f|f.js}
  end
  
  def destroy
    @comment.destroy
  end

  private
    def load_comment
      @comment = Comment.find(params[:id])
    end
    
    def save_uploads(comment)      
      params[:uploads].each do |upload_id|
        upload = Upload.find(upload_id)
        unless upload.nil?
          upload.comment_id = comment.id
          upload.save(false)
        end
      end unless params[:uploads].nil?
      
      params[:uploads_deleted].each do |upload_id|
        upload = Upload.find(upload_id)
        unless upload.nil?
          upload.destroy
        end
      end unless params[:uploads_deleted].nil?
    end
end