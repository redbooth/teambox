class JavascriptsController < ApplicationController
  def environment
    render :layout => false, :content_type => "application/x-javascript"
  end
end