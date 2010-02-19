class ExampleProjectsController < ApplicationController

  def new
  end

  def create
    @project = current_user.find_or_create_example_project

    unless current_user.can_create_project?
      flash[:error] = "You can't create any projects with your current account."
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