class PagesController < ApplicationController
  def index
    @pages = @current_project.pages
  end
  
  def new
    @page = Page.new
  end
  
  def create
    @page = @current_project.new_page(current_user,params[:page])
    @page.build_note({})
    
    respond_to do |f|
      if @page.save
        f.html{redirect_to edit_project_page_path(@current_project,@page)}
      else
        f.html{render :action => 'new'}
      end
    end
  end
  
  before_filter :load_page, :only => [ :edit, :update ]
  
  def edit
  end
  
  def update
    
    unless params[:notes].nil?
      position = 0
      params[:notes].each do |note_id|
        note = @page.notes.detect { |n| n.id == note_id.to_i }
        unless note.nil?
          note.position = position
          note.save(false)
          position += 1
        end
      end
      
      respond_to{|f|f.js}
    else
    
      respond_to do |f|
        if @page.update_attributes(params[:page])
          f.html {redirect_to edit_project_page_path(@current_project,@page)}
        else
          f.html {render :action => 'edit'}
        end
      end
      
    end
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:id])
    end
end