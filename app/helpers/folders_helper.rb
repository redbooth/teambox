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

  def target_folders_js
    folders = {}
    if @current_folder
      parent_folder_id = @parent_folder ? @parent_folder.id : nil
      folders[parent_folder_id.to_s] = "Move to parent folder"
    end
    @folders.each do |f|
      folders[f.id.to_s] = f.name
    end
    "target_folders = #{folders.to_json};" unless folders.empty?
  end

end