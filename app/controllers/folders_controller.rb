class FoldersController < ApplicationController

  def create
    authorize! :make_tasks, @current_project

    folder = @current_project.folders.new(params[:folder])
    folder.user_id = @current_user.id

    #respond_to do |f|
    if folder.save
      redirect_to project_folder_path(@current_project, folder)
    else
      flash[:error] = [t('folders.new.invalid_folder'), folder.errors.full_messages.to_sentence].join('. ')
      redirect_to project_uploads_path(@current_project)
    end

  end

end
