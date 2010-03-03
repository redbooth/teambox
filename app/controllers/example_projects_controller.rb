class ExampleProjectsController < ApplicationController
  before_filter :set_page_title

  def new
  end

  def create
    unless current_user.can_create_project?
      flash[:error] = "You can't create any projects with your current account."
      redirect_to root_path
      return
    end

    begin
      @project = current_user.find_or_create_example_project
    rescue Exception => e
      # Shouldn't happen. Most likely a problem with the projects, so check!
      projects_invalid = current_user.projects.reject{|p|p.valid?}.map{|p| "\"#{p.name}\""}
      
      if projects_invalid.empty?
        flash[:error] = "Could not create example project."
      else
        flash[:error] = "Could not create example project. The following projects are invalid: #{projects_invalid.join(',')}."
      end
      redirect_to root_path
      return
    end

    if @project
      redirect_to @project
    else
      raise "Error accessing example project!"
    end
  end

end