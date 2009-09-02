class PhotoFilesController < ApplicationController
  # GET /photo_files
  # GET /photo_files.xml
  def index
    @photo_files = PhotoFile.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_files }
    end
  end

  # GET /photo_files/1
  # GET /photo_files/1.xml
  def show
    @photo_file = PhotoFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_file }
    end
  end

  # GET /photo_files/new
  # GET /photo_files/new.xml
  def new
    @photo_file = PhotoFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_file }
    end
  end

  # GET /photo_files/1/edit
  def edit
    @photo_file = PhotoFile.find(params[:id])
  end

  # POST /photo_files
  # POST /photo_files.xml
  def create
    @photo_file = PhotoFile.new(params[:photo_file])

    respond_to do |format|
      if @photo_file.save
        flash[:notice] = 'PhotoFile was successfully created.'
        format.html { redirect_to(@photo_file) }
        format.xml  { render :xml => @photo_file, :status => :created, :location => @photo_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_files/1
  # PUT /photo_files/1.xml
  def update
    @photo_file = PhotoFile.find(params[:id])

    respond_to do |format|
      if @photo_file.update_attributes(params[:photo_file])
        flash[:notice] = 'PhotoFile was successfully updated.'
        format.html { redirect_to(@photo_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_files/1
  # DELETE /photo_files/1.xml
  def destroy
    @photo_file = PhotoFile.find(params[:id])
    @photo_file.destroy

    respond_to do |format|
      format.html { redirect_to(photo_files_url) }
      format.xml  { head :ok }
    end
  end
end
