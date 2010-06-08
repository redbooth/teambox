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
    @activities = Project.get_activities_for @target, :before => params[:id]
    @last_activity = @activities.last
    
    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js
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
      format.js
      format.xml  { render :xml     => @activities.to_xml }
      format.json { render :as_json => @activities.to_xml }
      format.yaml { render :as_yaml => @activities.to_xml }
    end
  end

  private
    # Assigns @target, depending of the value of :project_id in the URL
    # * All projects if it's not defined
    # * The requested project if given
    def get_target
      @target = if params[:project_id]
        @current_user.projects.find_by_permalink(params[:project_id])
      else
        @current_user.projects.find :all
      end
      
      unless @target
        redirect_to '/'
        return false
      end
    end
end