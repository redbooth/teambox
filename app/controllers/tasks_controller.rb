class TasksController < ApplicationController

  around_filter :set_time_zone, :only => [:show]
  before_filter :load_task, :except => [:new, :create]
  before_filter :load_task_list, :only => [:new, :create]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    handle_cancan_error(exception)
  end

  def show
    authorize! :show, @task
    respond_to do |f|
      f.any(:html, :m)
      f.js {
        @show_part = params[:part]
        render :template => 'tasks/reload'
      }
    end
  end

  def new
    authorize! :make_tasks, @current_project
    @task = @task_list.tasks.new
    
    respond_to do |f|
      f.any(:html, :m)
    end
  end

  def create
    authorize! :make_tasks, @current_project
    @task = @task_list.tasks.build_by_user(current_user, params[:task])
    @task.is_private = (params[:task][:is_private]||false) if params[:task]
    @task.save
    
    respond_to do |f|
      f.any(:html, :m) {
        if @task.new_record?
          render :new
        else
          redirect_to_task
        end
      }
      f.js {
        if @task.new_record?
          output_errors_json(@task)
        else
          response.content_type = Mime::HTML
          render(:partial => 'tasks/task', :locals => {
            :project => @current_project,
            :task_list => @task_list,
            :task => @task.reload,
            :editable => true
          })
        end
      }
    end
  end

  def edit
    authorize! :update, @task
    respond_to do |f|
      f.any(:html, :m)
      f.js { render :layout => false }
    end
  end

  def update
    if can? :update, @task
      @task.updating_user = current_user
      success = @task.update_attributes params[:task]
    elsif can? :comment, @task
      @task.updating_user = current_user
      success = @task.update_attributes(:comments_attributes => params['task']['comments_attributes'])
    else
      authorize! :comment, @task
    end

    respond_to do |f|
      f.any(:html, :m) {
        if request.xhr? or iframe?
          if success and @task.comment_created?
            comment = @task.comments(true).first
            response.headers['X-JSON'] = @task.to_json(:include => :assigned)

            render :partial => 'comments/comment',
              :locals => { :comment => comment }
          else
            render :nothing => true
          end
        else
          if success
            redirect_to_task
          else
            render :edit
          end
        end
      }
      f.js {
        if params[:task][:name]
          head :ok
        end
      }
    end
  end

  def destroy
    authorize! :destroy, @task
    @task.destroy

    respond_to do |f|
      f.any(:html, :m) {
        flash[:success] = t('deleted.task', :name => @task.to_s)
        redirect_to [@current_project, @task_list]
      }
      f.js { render :layout => false }
    end
  end

  def reorder
    authorize! :reorder_objects, @current_project
    target_task_list = @current_project.task_lists.find params[:task_list_id]
    if @task.task_list != target_task_list
      @task.task_list = target_task_list
      @task.save
    end

    task_ids = params[:task_ids].split(',').collect {|t| t.to_i}
    target_task_list.tasks.each do |t|
      next unless task_ids.include?(t.id)
      Task.thin_model.find(t.id).update_attribute :position, task_ids.index(t.id)
    end

    head :ok
  end

  def watch
    authorize! :watch, @task
    @task.add_watcher(current_user)
    respond_to do |f|
      f.js { render :layout => false }
    end
  end

  def unwatch
    @task.remove_watcher(current_user)
    respond_to do |f|
      f.js { render :layout => false }
    end
  end

  private

    def load_task_list
      @task_list = if params[:id]
        @current_project.tasks.find(params[:id]).task_list
      elsif params[:task_list_id]
        @current_project.task_lists.find params[:task_list_id]
      end
    end

    def load_task
      @task = @current_project.tasks.find params[:id]
      @task_list = @task.task_list
    end
    
    def redirect_to_task
      redirect_to [@current_project, @task]
    end
end
