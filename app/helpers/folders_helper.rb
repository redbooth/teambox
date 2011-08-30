module FoldersHelper

  def folder_breadcrumbs
    folder = @current_folder
    bc = []
    until folder.nil? do
      bc << (folder == @current_folder ? folder.name : link_to(folder.name, project_folder_path(@current_project, folder), :remote => true))
      folder = folder.parent_folder
    end
    bc << link_to(@current_project, project_uploads_path(@current_project), :remote => true)
    bc.reverse.join(" » ").html_safe
  end
  
  def json_target_folders
     target_folders = []
     if @current_folder
      parent_folder_id = @parent_folder ? @parent_folder.id : nil
      target_folders = [{:id => parent_folder_id, :name => t('uploads.moveable.to_parent')}]
     end
     folders = @current_folder ? @current_folder.folders.order('name ASC') : @current_project.folders.where(:parent_folder_id => nil).order('name ASC')
     target_folders+= folders.empty? ? [] : folders.map {|f| {:id => f.id, :name => f.name}}
     target_folders.to_json
  end

end