class ExampleProjectsController < ApplicationController

  def new
  end

  def create
    @project = current_user.find_or_create_example_project

    if @project
      redirect_to @project
    else
      raise "Error accessing example project!"
    end
  end

end