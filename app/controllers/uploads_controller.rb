class UploadsController < ApplicationController
  before_filter :find_upload, :only => [:destroy,:update,:thumbnail,:show]
  skip_before_filter :load_project, :only => [:download]
  SEND_FILE_METHOD = :default

  def download

    head(:not_found) and return if (upload = Upload.find_by_id(params[:id])).nil?
    head(:forbidden) and return unless upload.downloadable?(current_user)

    path = upload.asset.path(params[:style])
    unless File.exist?(path) && params[:filename].to_s == upload.asset_file_name
      head(:bad_request)
      raise "Unable to download file"
    end  

    mime_type = File.mime_type?(upload.asset_file_name)

    mime_type = 'application/octet-stream' if mime_type == 'unknown/unknown'

    send_file_options = { :type => mime_type }
    
    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end
  
  def new
    @upload = current_user.uploads.new
    respond_to { |f| f.html }
  end
  
  def index
    @uploads = @current_project.uploads
  end
  
  def edit
    @upload = @current_project.uploads.find(params[:id])
  end
  
  def new
    @comment = load_comment
    @upload = @current_project.uploads.new(:user_id => current_user.id)
    if is_iframe?
      respond_to { |f| f.html { render :layout => 'upload_iframe' }}
    else
      respond_to { |f| f.html { render :template => 'uploads/new_upload' } }
    end
  end
  
  def create
    @upload = @current_project.uploads.new(params[:upload])
    @upload.user = current_user

    
    if is_iframe?
      @upload.save
      @comment = load_comment
      @upload.reload
      respond_to{|f|f.html {render :template => 'uploads/create', :layout => 'upload_iframe'} }

    else
      respond_to do |f|          
        if @upload.save
          @current_project.log_activity(@upload,'create')
        else
          flash[:error] = "Couldn't upload file"
        end   
        f.html { redirect_to(project_uploads_path(@current_project)) }
      end
    end
  end

  
  def update
    @upload.update_attributes(params[:upload])

    respond_to do |format|
      format.js
      format.html { redirect_to(project_uploads_path(@current_project)) }
    end
  end
      
  def destroy
    if @upload
      @upload.destroy
    end
  end
    
  private
    def is_iframe?
      params[:iframe] != nil
    end
        
    def load_comment
      if params[:comment_id]
        Comment.find(params[:comment_id])
      else
        @current_project.comments.new(:user_id => current_user.id)
      end
    end
    
    def find_upload
      if params[:id].match /^\d+$/
        @upload = @current_project.uploads.find(params[:id])
      else
        @upload = @current_project.uploads.find_by_upload_file_name(params[:id])
      end
      
    end
end