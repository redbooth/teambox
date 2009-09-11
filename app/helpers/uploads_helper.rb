module UploadsHelper
  def upload_link(upload)
    if upload.is_image?
      link_to image_tag(thumbnail_project_upload_path(upload.project,upload)),
        project_upload_path(upload.project,upload.image_filename),
        :class => 'link_to_upload'
    else
      link_to image_tag('rails.png'),
        project_upload_path(upload.project,upload.image_filename),
        :class => 'link_to_upload'
    end
  end

  def upload_a_file_link(comment)
    render :partial => 'uploads/link', :locals => { :comment => comment }
  end
  
  def show_upload_form(comment)
    update_page do |page|
        page << "this.insert("
        page << { :after => render(
          :partial => 'uploads/iframe_upload', 
          :locals => { :comment => comment, :project => comment.project })}.to_json
        page << ");"
    end
  end
  
  def upload_form_url_for(comment)
    if comment.new_record?
      project_uploads_url(comment.project)
    else
      project_comment_uploads_url(comment.project,comment)
    end
  end
  
  def upload_url_for(comment)
    if comment.new_record?
      new_project_upload_url(comment.project)
    else
      new_project_comment_upload_url(comment.project,comment)
    end
  end
  
  def list_uploads_edit(uploads,target)
    render :partial => 'uploads/upload_edit', :collection => uploads, :as => :upload, :locals => { :target => target }
  end
  
  def list_uploads_inline(uploads)
    render :partial => 'uploads/upload', :collection => uploads, :as => :upload
  end
  
  def observe_upload_form
    update_page_tag do |page|
      page['new_upload'].observe('submit') do |page|
        page.select('.upload_button').invoke('hide')
        page['upload_loading'].show
      end
    end
  end
  
  def cancel_upload_form_link
    link_to_function 'cancel', cancel_upload_form
  end
  
  def cancel_upload_form
    update_page do |page|
      page << "window.frameElement.remove();"
    end
  end
  
  def delete_upload_link(upload,target)
    link_to_function 'D', delete_upload(upload,target)
  end
  
  def upload_save_tag(name,upload)
    content_tag(:input,nil,{ :name => name,:type => 'hidden',:value => upload.id.to_s })
  end
  
  def delete_upload(upload,target)
    if target.new_record?
      update_page do |page|
        page["upload_#{upload.id}"].up('.uploads_current') \
          .previous('.uploads_save').select("input[value=#{upload.id}]") \
          .invoke('remove')
        page << "var uploads_current = $('upload_#{upload.id}').up('.uploads_current');"
        page["upload_#{upload.id}"].remove
        page << "Comment.update_uploads_current(uploads_current);"
      end
    else
      update_page do |page|
        page << "$('upload_#{upload.id}').up('.uploads_current')" + \
          ".previous('.uploads_save').insert(" + \
          { :top => upload_save_tag('uploads_deleted[]',upload) }.to_json + ");"
        page["upload_#{upload.id}"].remove
      end
    end
  end
end
