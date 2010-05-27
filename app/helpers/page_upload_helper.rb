module PageUploadHelper
  
  def new_page_upload_link(project,page,in_bar)
    link_to "<span>#{t('.new_upload')}</span>", new_project_page_upload_path(project, page), :class => 'add_button upload_button'
  end
  
  def cancel_page_upload_link
    link_to t('common.cancel'), '#', :class => 'cancel'
  end
end