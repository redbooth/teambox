class PagesController < ApplicationController
  def index
    @pages = @current_project.pages
  end
  
  def new
    @page = Page.new
  end
  
  def create
    @page = @current_project.new_page(current_user,params[:page])
    
    respond_to do |f|
      if @page.save
        f.html{redirect_to edit_project_page_path(@current_project,@page)}
      else
        f.html{render :action => 'new'}
      end
    end
  end
  
  before_filter :load_page, :only => [ :edit, :update, :rename, :insert_divider, :section_divider ]
  
  def rename
  end
  
  def section_divider
    @pid = params[:pid]
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @page.update_attributes(params[:page])
        f.html {redirect_to project_page_path(@current_project,@page)}
        f.js
      else
        f.html {render :action => 'edit'}
        f.js
      end
    end
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:id])
    end
end