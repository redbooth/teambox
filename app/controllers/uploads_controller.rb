class UploadsController < ApplicationController
  before_filter :find_upload, :only => [ :destroy, :update, :thumbnail, :show ]
  
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
    load_target
    @upload = @current_project.uploads.new(:user_id => current_user.id)
    if is_iframe?
      respond_to { |f| f.html { render :layout => 'upload_iframe' }}
    else
      respond_to { |f| f.html { render :template => 'uploads/new_upload' } }
    end
  end
  
  def update
    @upload.update_attributes(params[:upload])
    @upload.save

    respond_to do |f|
      f.js
      f.html { redirect_to(project_uploads_path(@current_project)) }
    end
  end
  
  def create
    @upload = @current_project.uploads.new(params[:upload])
    @upload.user = current_user

    load_target
    @upload.save
    if is_iframe?
      respond_to{|f|f.html {render :template => 'uploads/create', :layout => 'upload_iframe'} }
    else
      respond_to{|f|f.html {redirect_to(project_uploads_path(@current_project))}}
    end
  end
  
  def show
    if @upload
      render :inline => "@upload.operate { |p| }", :type => :flexu
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
      render :inline => "@upload.operate {|p| p.resize '64x64'}", :type => :flexu
    end
  end
  
  private
    def is_iframe?
      params[:iframe] != nil
    end
    
    def load_target
      unless params[:comment_id].nil?
        @target = Comment.find(params[:comment_id])
      else
        @target = @current_project.comments.new(:user_id => current_user.id)
      end
    end
    
    def find_upload
      if params[:id].match /^\d+$/
        @upload = @current_project.uploads.find(params[:id])
      else
        @upload = @current_project.uploads.find_by_filename(params[:id])
      end
      
    end
end