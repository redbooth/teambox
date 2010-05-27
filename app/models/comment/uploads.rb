class Comment
  
  def save_uploads(params)      
    (params[:uploads] || []).each do |upload_id|
      if upload = Upload.find(upload_id)
        upload.comment_id = self.id
        upload.description = truncate(h(upload.comment.body), :length => 80)
        upload.save(false)
      end
    end

    clean_deleted_uploads(params)
  end
  
  protected
  
    def clean_deleted_uploads(params)
      (params[:uploads_deleted] || []).each do |upload_id|
        upload = Upload.find(upload_id)
        upload.destroy if upload
      end
    end
  
end