class TeamboxDatasController < ApplicationController
  skip_before_filter :load_project
  before_filter :find_data, :except => [:index, :new, :create]
  
  def index
    # show current imports/exports
    @data_imports = current_user.teambox_datas.find_all_by_type_id(0)
    @data_exports = current_user.teambox_datas.find_all_by_type_id(1)
    
    respond_to do |f|
      f.html
    end
  end
  
  def show
    respond_to do |f|
      if @data.type_name == :import and @data.need_data? and @data.data == nil
        @data.status_name = :uploading
        @data.processed_data_file_name = nil
        @data.save
        flash.now[:error] = t('teambox_datas.show_import.import_error')
        f.html { render view_for_data(:show) }
      else
        f.html { render view_for_data(:show) }
      end
    end
  end
  
  def new
    @data = current_user.teambox_datas.build(:service => 'teambox')
    @data.type_name = params[:type]
    
    respond_to do |f|
      f.html { render view_for_data(:new) }
    end
  end
  
  def create
    @data = current_user.teambox_datas.build(params[:teambox_data])
    
    respond_to do |f|
      if @data.save
        f.html { redirect_to teambox_data_path(@data) }
      else
        flash.now[:error] = "There were errors with the information you supplied!"
        f.html { render view_for_data(:new) }
      end
    end
  end
  
  def update
    respond_to do |f|
      if !@data.processing? and !@data.update_attributes(params[:teambox_data])
        if @data.status_name == :uploading
          flash.now[:error] = t('teambox_datas.show_import.import_error')
        end
        f.html { render view_for_data(:show) }
      else
        if @data.processing?
          f.html { redirect_to teambox_data_path(@data) }
        else
          flash.now[:error] = "There were errors with the information you supplied!"
          f.html { render view_for_data(:show) }
        end
      end
    end
  end
  
  def destroy
    @data.destroy
    
    respond_to do |f|
      f.html { redirect_to teambox_datas_path }
    end
  end
  
  def download
    head(:forbidden) and return unless @data.downloadable?(current_user)
    
    if Teambox.config.amazon_s3
      redirect_to @data.processed_data.url
    else
      path = @data.processed_data.path
      unless File.exist?(path)
        head(:bad_request)
        raise "Unable to download file"
      end

      mime_type = File.mime_type?(@data.processed_data_file_name)
      mime_type = 'application/octet-stream' if mime_type == 'unknown/unknown'

      send_file_options = { :type => mime_type }
      response.headers['Cache-Control'] = 'private, max-age=31557600'

      send_file(path, send_file_options)
    end
  end
  
private

  def find_data
    unless @data = TeamboxData.find_by_id(params[:id])
      flash[:error] = t('not_found.data')
      redirect_to teambox_datas_path
    end
  end
  
  def view_for_data(action)
    "#{action}_#{@data.type_name}"
  end
  
end
