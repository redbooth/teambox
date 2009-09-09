class UploadsController < ApplicationController
  before_filter :find_upload, :only => [ :destroy, :update, :thumbnail, :show ]

  def find_upload
    if params[:id].match /^\d+$/
      @upload = @current_project.uploads.find(params[:id])
    else
      @upload = @current_project.uploads.find_by_image_filename(params[:id])
    end
  end

  def index
    @uploads = @current_project.uploads
  end
  
  def new
    @upload = current_user.uploads.new
    respond_to { |f| f.html }
  end
  
  def update
    @upload.update_attributes(params[:upload])
  end
  
  def create
    tmp_filename = params[:upload][:file].original_filename
    mime_type = MIME::Types.type_for(tmp_filename).to_s
    
    # If the upload is an image this will pass the image to FlexImage
    # Otherwise the file will be handled by file_column
    if mime_type.match /^image/
      params[:upload][:image_file] = params[:upload][:file]
      params[:upload][:file] = nil
    end
    
    @upload = @current_project.uploads.new(params[:upload])
    @upload.user = current_user
    @upload.content_type = mime_type
    @upload.image_filename = tmp_filename

    if is_iframe?
      load_target
      @upload.save
      respond_to{|f|f.html {render :template => 'uploads/create', :layout => 'upload_iframe'} }
    else
      respond_to do |format|
        if @upload.save
          format.html { redirect_to(project_uploads_path) }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end
  
  def show
    if @upload
      if @upload.is_image?
        render :inline => "@upload.operate { |p| }", :type => :flexi
      else
        send_file @upload.pathname, :content_type => @upload.content_type
      end
    else
      flash[:notice] = "#{params[:upload_fileame]} could not be found."
      redirect_to project_uploads_path(@current_project)
    end
  end
  
  def destroy
    if @upload
      @upload.destroy
    end
  end
  
  def thumbnail
    if @upload and @upload.is_image?
      render :inline => "@upload.operate {|p| p.resize '64x64'}", :type => :flexi
    end
  end
  
  def iframe
    #unless Upload::TARGET_TYPES.include?(params[:target_type])
    #  redirect_to root_path
    #end
    
    load_target
    @upload = @current_project.new_upload(current_user)
    
    render :layout => 'upload_iframe'
  end
  
  private
    def is_iframe?
      params[:iframe] != nil and !params[:iframe].empty?
    end
    
    def has_target?
      params[:target_id] != nil and !params[:target_id].empty?
    end
    
    def load_target
      if has_target?
        @target = params[:target_type].singularize.camelize.constantize.find(params[:target_id])
      else
        @target = params[:target_type].singularize.camelize.constantize.new
      end
    end
end