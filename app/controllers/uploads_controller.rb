class UploadsController < ApplicationController
  before_filter :find_upload, :only => [:destroy,:update,:thumbnail,:show]
  skip_before_filter :load_project, :only => [:download]
  before_filter :set_page_title
  
  SEND_FILE_METHOD = :default
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |f|
      error_message = "You are not allowed to do that!"
      f.js             { render :text => "alert('#{error_message}')" }
      f.any(:html, :m) { render :text => "alert('#{error_message}')" }
    end
  end

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

    response.headers['Cache-Control'] = 'private, max-age=31557600'

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end
  
  def index
    @uploads = @current_project.uploads.order('updated_at DESC')
    @upload ||= @current_project.uploads.new
  end

  def show
    redirect_to @upload.url
  end

  def new
    authorize! :upload_files, @current_project
    @upload = @current_project.uploads.new
    @upload.user = current_user
  end  
  
  def create
    authorize! :upload_files, @current_project
    authorize! :update, @page if @page
    @upload = @current_project.uploads.new params[:upload]
    @upload.user = current_user
    @page = @upload.page
    calculate_position(@upload) if @page
    
    @upload.save

    respond_to do |wants|
      wants.any(:html, :m) {
        if @upload.new_record?
          flash.now[:error] = "There was an error uploading the file"
          render :new
        elsif @upload.page
          if iframe?
            code = render_to_string 'create.js.rjs', :layout => false
            render :template => 'shared/iframe_rjs', :layout => false, :locals => { :code => code }
          else
            redirect_to [@current_project, @upload.page]
          end
        else
          redirect_to [@current_project, :uploads]
        end
      }
    end
  end

  def update
    authorize! :update, @upload
    @upload.update_attributes(params[:upload])

    respond_to do |format|
      format.js   { render :layout => false }
      format.any(:html, :m)  { redirect_to project_uploads_path(@current_project) }
    end
  end

  def destroy
    authorize! :destroy, @upload
    @slot_id = @upload.page_slot.try(:id)
    @upload.try(:destroy)

    respond_to do |f|
      f.js   { render :layout => false }
      f.any(:html, :m) do
        flash[:success] = t('deleted.upload', :name => @upload.to_s)
        redirect_to project_uploads_path(@current_project)
      end
    end
  end
  
  private
    
    def find_upload
      if params[:id].to_s.match /^\d+$/
        @upload = @current_project.uploads.find(params[:id])
      else
        @upload = @current_project.uploads.find_by_asset_file_name(params[:id])
      end
    end

end
