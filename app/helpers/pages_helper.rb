module PagesHelper
  def new_page_link(project)
    link_to 'New Page', new_project_page_path(project)
  end
  
  def page_fields(f)
    render :partial => 'pages/fields', :locals => { :f => f }
  end
end