module PageUploadHelper
  
  def new_page_upload_link(project,page)
    link_to_remote "<span>#{t('.new_upload')}</span>",
      :url => new_project_page_upload_path(project,page),
      :method => :get,
      :html => { :class => 'add_button' }
  end  
  
end