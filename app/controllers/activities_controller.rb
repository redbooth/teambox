class ActivitiesController < ApplicationController

  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user

  before_filter :get_target

  def show # also handles #index, see routes.rb
    @activities = Activity.for_projects(@target).
      where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON  ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.target_id = watchers.watchable_id AND watchers.watchable_type = activities.target_type)) AND watchers.user_id = #{current_user.id}")
    
    @threads = @activities.threads
    @last_activity = @threads.all.last

    respond_to do |format|
      format.html do
        if params[:nolayout]
          @new_conversation = Conversation.new(:simple => true)
          @projects = current_user.projects.unarchived
          render :layout => false
        else
          redirect_to projects_path
        end
      end
      format.m
    end
  end

  def show_more
    @activities = if @user
      Activity.for_projects(@target).before(Activity.find(params[:id])).from_user(@user)
    else
      Activity.for_projects(@target).before(Activity.find(params[:id]))
    end.
      where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.target_id = watchers.watchable_id AND watchers.watchable_type = activities.target_type)) AND watchers.user_id = #{current_user.id}")
    
    @threads = @activities.threads
    @last_activity = @threads.all.last

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js   { render :layout  => false }
    end
  end

  def show_thread
    # FIXME: insecure!
    target = params[:thread_type].constantize.find params[:id]
    authorize! :show, target

    @comments = target.comments
    
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => 'comments/comment',
            :collection => @comments.reverse
        end
      }
    end
  end

  private
    # Assigns @target, depending of the value of :project_id in the URL
    # * All projects if it's not defined
    # * The requested project if given
    def get_target
      @target = if params[:project_id]
        @current_project = Project.find_by_permalink(params[:project_id])
        if @current_project
          unless @current_user.project_ids.include?(@current_project.id) ||
                 @current_project.organization.is_admin?(current_user)
            @current_project = nil
          end
        end
        @current_project
      elsif params[:user_id]
        @user = User.find_by_id(params[:user_id])
        @user.projects_shared_with(@current_user)
      else
        @current_user.projects.find :all
      end
      
      redirect_to root_path if @target.nil? or (@user and @target.empty?)
    end
end
