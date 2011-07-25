class FoldersController < ApplicationController

  def create
    #authorize! :make_tasks, @current_project

    params[:folder].merge!({:user_id => current_user.id, :project_id => @current_project.id})

    if folder = Folder.create(params[:folder])
      redirect_to project_folder_path(@current_project, folder)
    else
      flash[:error] = [t('folders.new.invalid_folder'), folder.errors.full_messages.to_sentence].join('. ')
      redirect_to project_uploads_path(@current_project)
    end

  end

  def destroy
    #authorize! :destroy, @folder

    @folder = @current_project.folders.find_by_id(params[:id])
    @parent_folder = @folder.parent_folder
    @folder.destroy

    respond_to do |f|
      f.js   { render :layout => false }
      f.any(:html, :m) do
        flash[:success] = t('deleted.folder', :name => @folder.name)
        redirect_to @parent_folder.nil? ? project_uploads_path(@current_project) : project_folder_path(@current_project, @parent_folder)
      end
    end
  end

end
