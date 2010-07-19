class ApiV1::APIController < ApplicationController
  # Common api helpers
  
  def api_created(path)
    respond_to do |format|
      f.json { redirect_to path }
    end
  end
  
  def api_updated(object, status)
    respond_to do |format|
      f.json { render :as_json => object.to_xml, :status => status }
    end
  end
  
  def api_deleted
    respond_to do |format|
      f.json { render :text => '', :status => :deleted }
    end
  end
  
  def api_error(message, status)
    error = {'error' => message}
    respond_to do |format|
      f.json { render :as_json => error.to_xml, :status => status }
    end
  end
  
  def handle_api_error(f,object)
    error_list = object.nil? ? [] : object.errors
    f.json { render :as_json => error_list.to_xml, :status => :unprocessable_entity }
  end
  
  def handle_api_success(f,object,is_new=false)
    if is_new
      f.json { render :as_json => object.to_xml, :status => :created }
    else
      f.json { head :ok }
    end
  end
end