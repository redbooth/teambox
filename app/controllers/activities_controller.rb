class ActivitiesController < ApplicationController

  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user

  before_filter :get_target

  def show
    @activities = Project.get_activities_for @target
    @last_activity = @activities.last

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.m
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_more
    opts = {:before => params[:id]}
    opts[:user_id] = @user.id if @user
    
    @activities = Project.get_activities_for @target, opts
    @last_activity = @activities.last
    
    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { @threads = Activity.get_threads(@activities) }
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_new
    @activities = Project.get_activities_for @target, :after => params[:id]
    @last_activity = @activities.last
    
    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { @threads = Activity.get_threads(@activities) }
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  def show_thread
    if params[:thread_type] == "Task"
      target = Task.find(params[:id])
    else
      target = Conversation.find(params[:id])
    end
    @comments = target ? target.comments.all : []
    @comments.pop if target.is_a?(Conversation) and target.simple
    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js
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
      
      if @target.nil? or (@user and @target.empty?)
        redirect_to '/'
        return false
      end
    end
end