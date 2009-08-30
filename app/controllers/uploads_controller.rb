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
    @upload = @current_project.uploads.new(params[:upload])

    respond_to do |format|
      if @upload.save
        format.html { redirect_to(project_uploads_path) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def show
    if @upload
      render :inline => "@upload.operate { |p| }", :type => :flexi
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
    if @upload
      if @upload.is_image?
        render :inline => "@upload.operate {|p| p.resize '64x64'}", :type => :flexi
      end
    end
  end
  
  def iframe
    @upload = @current_course.uploads.new
    render :layout => 'upload_iframe'
  end
end