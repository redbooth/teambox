module FoldersHelper

  def folder_breadcrumbs
    folder = @current_folder
    bc = []
    until folder.nil? do
      bc << (folder == @current_folder ? folder.name : link_to(folder.name, project_folder_path(@current_project, folder)))
      folder = folder.parent_folder
    end
    bc << link_to(@current_project, project_uploads_path(@current_project))
    bc.reverse.join(" » ").html_safe
  end

end