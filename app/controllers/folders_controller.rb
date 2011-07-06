class FoldersController < ApplicationController

  def create
    authorize! :make_tasks, @current_project

    @folder = @current_project.folders.new(params[:folder])
    @folder.user_id = @current_user.id

    #respond_to do |f|
      if @folder.save
        redirect_to project_uploads_path(@project)
      else
        flash.now[:error] = t('folders.new.invalid_folder')
      end
    #end
  end

end
