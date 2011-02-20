class ActivitiesController < ApplicationController

  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user

  before_filter :get_target

  def show # also handles #index, see routes.rb
    @activities = Activity.for_projects(@target)
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
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_more
    @activities = if @user
      Activity.for_projects(@target).before(params[:id]).from_user(@user)
    else
      Activity.for_projects(@target).before(params[:id])
    end
    @threads = @activities.threads
    @last_activity = @threads.all.last

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js   { render :layout  => false }
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_new
    @activities = Activity.for_projects(@target).after(params[:id])
    @threads = @activities.threads
    @last_activity = @threads.all.last

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { render :layout => false }
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_thread
    # FIXME: insecure!
    target = params[:thread_type].constantize.find params[:id]

    @comments = target.comments
    
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => 'comments/comment',
            :collection => @comments.reverse,
            :locals => { :threaded => true }
        end
      }
      format.xml  { render :xml     => @comments.to_xml }
      format.json { render :as_json => @comments.to_xml }
      format.yaml { render :as_yaml => @comments.to_xml }
    end
  end

  private
    # Assigns @target, depending of the value of :project_id in the URL
    # * All projects if it's not defined
    # * The requested project if given
    def get_target
      @target = if params[:project_id]
        @current_project = @current_user.projects.find_by_permalink(params[:project_id])
      elsif params[:user_id]
        @user = User.find_by_id(params[:user_id])
        @user.projects_shared_with(@current_user)
      else
        @current_user.projects.find :all
      end
      
      redirect_to root_path if @target.nil? or (@user and @target.empty?)
    end
end
