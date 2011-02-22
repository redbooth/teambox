module UploadsHelper
  
  def upload_primer(project)
    render 'uploads/primer', :project => project
  end
  
  def link_to_upload(upload, text, attributes = {})
    link_to(h(text), upload.url, {:rel => (upload.image? ? 'facebox' : nil), :target => (upload.image? ? nil : '_blank')}.merge(attributes))
  end
  
  def upload_link_with_thumbnail(upload)
    link_to image_tag(upload.url(:thumb)),
      upload.url,
      :class => 'link_to_upload', :rel => 'facebox'
  end
  
  def page_upload_actions_link(page, upload)
    if current_user && can?(:update, upload)
      render 'uploads/slot_actions', :upload => upload, :page => page
    end
  end
  
  def list_uploads_inline(uploads)
    render :partial => 'uploads/file', :collection => uploads, :as => :upload
  end

  def list_uploads_inline_with_thumbnails(uploads)
    render :partial => 'uploads/thumbnail', :collection => uploads, :as => :upload
  end
  
  def file_icon_image(upload,size='48px')
    filename = upload.is_a?(String) ? upload : upload.file_name
    
    extension = File.extname(filename)
    if extension.length > 0
      extension = extension[1,10]
    end
    
    if Upload::ICONS.include?(extension)
      image_tag("file_icons/#{size}/#{extension}.png", :class => "file_icon #{extension}")
    else
      image_tag("file_icons/#{size}/_blank.png")
    end
  end
  
end
