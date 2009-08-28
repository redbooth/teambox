class DividersController < ApplicationController  
  before_filter :load_page
  
  def new

  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
end