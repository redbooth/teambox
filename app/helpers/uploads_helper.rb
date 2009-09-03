module UploadsHelper

  def new_file_link(course)
    link_to t('.new_file'), new_project_upload_path(@current_project)
  end

  def upload_link(upload)
    link_to h(upload.image_filename), project_upload_path(@current_project,upload.image_filename), :class => 'link_to_file'
  end
  
  def observe_upload_save(upload)
    update_page_tag do |page|
      page["save_upload_#{upload.id}"].observe('click') do |page|
        page.show_loading('update',upload.id)
      end
    end
  end
  
  def edit_upload_link(upload)
    link_to_function pencil_image, edit_upload_form(upload), :class => 'edit_upload_link'
  end
  
  def delete_upload_link(upload)
    link_to_remote trash_image, 
      :url => project_upload_path(@current_project,upload), 
      :method => :delete, 
      :class => 'delete_link', 
      :confirm => "Are you sure you want to delete this file?"
  end
    
  def edit_upload_form(upload)
    update_page do |page|
      page["upload_#{upload.id}"].down('.show_details').hide
      page["upload_#{upload.id}"].down('.edit_details').show
    end
  end
  
  def hide_upload_form(upload)
    page["upload_#{upload.id}"].down('.show_details').show
    page["upload_#{upload.id}"].down('.edit_details').hide
  end
  
  def cancel_edit_link(upload)
    link_to_function 'cancel', update_page { |page| page.hide_upload_form(upload) }
  end
  
  def show_loading(action,id = nil)
    if id
      page["#{action}_loading_#{id}"].show
    else
      page["#{action}_loading"].show
    end
  end

  def hide_loading(action,id = nil)
    if id
      page["#{action}_loading_#{id}"].hide
    else
      page["#{action}_loading"].hide
    end
  end
end
