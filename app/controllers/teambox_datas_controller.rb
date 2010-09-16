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
      if @data.type_name == :import and @data.data == nil
        @data.destroy
        flash[:error] = t('teambox_datas.show_import.import_error')
        f.html { redirect_to teambox_datas_path }
      else
        f.html { render view_for_data(:show) }
      end
    end
  end
  
  def new
    # create import/export
    @data = current_user.teambox_datas.build()
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
        f.html { render view_for_data(:new) }
      end
    end
  end
  
  def update
    @data.ready = true
    
    respond_to do |f|
      if @data.update_attributes(params[:teambox_data])
        f.html { redirect_to teambox_datas_path }
      else
        flash.now[:error] = "There were errors with the information you supplied!"
        f.html { render view_for_data(:show) }
      end
    end
  end
  
  def destroy
    @data.destroy
    
    respond_to do |f|
      f.html { redirect_to teambox_datas_path }
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
