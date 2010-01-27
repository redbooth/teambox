module PageUploadHelper
  
  def new_page_upload_link(project,page,in_bar)
    link_to_function "<span>#{t('.new_upload')}</span>", show_page_upload_form(in_bar), :class => 'add_button'
  end
  
  def cancel_page_upload_link
    link_to t('common.cancel'), '#', :class => 'cancel'
  end
  
  def show_page_upload_form(in_bar)
    update_page do |page|
      unless in_bar
        page.call "InsertionMarker.set", nil, true
        page.call "InsertionBar.place"
      end
      
      page.call "InsertionMarker.setEnabled", true
      page.call "InsertionBar.clearWidgetForm"
      page.call "InsertionBar.insertTempForm", (render :partial => 'uploads/page_upload')
      page.reload_javascript_events
    end  
  end
end