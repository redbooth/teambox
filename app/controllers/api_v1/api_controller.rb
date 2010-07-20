class ApiV1::APIController < ApplicationController
  # Common api helpers
  
  def api_status(status)
    respond_to do |f|
      f.json { head :status }
    end
  end
  
  def api_error(message, status)
    error = {'message' => message}
    respond_to do |f|
      f.json { render :as_json => error.to_xml(:root => 'error'), :status => status }
    end
  end
  
  def handle_api_error(f,object,options={})
    error_list = object.nil? ? [] : object.errors
    f.json { render :as_json => error_list.to_xml, :status => options.delete(:status) || :unprocessable_entity }
  end
  
  def handle_api_success(f,object,options={})
    if options.delete(:is_new)
      f.json { render :as_json => object.to_xml, :status => options.delete(:status) || :created }
    else
      f.json { head(options.delete(:status) || :ok) }
    end
  end
end