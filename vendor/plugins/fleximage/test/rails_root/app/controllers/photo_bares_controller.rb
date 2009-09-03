class PhotoBaresController < ApplicationController
  # GET /photo_bares
  # GET /photo_bares.xml
  def index
    @photo_bares = PhotoBare.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_bares }
    end
  end

  # GET /photo_bares/1
  # GET /photo_bares/1.xml
  def show
    @photo_bare = PhotoBare.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_bare }
    end
  end

  # GET /photo_bares/new
  # GET /photo_bares/new.xml
  def new
    @photo_bare = PhotoBare.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_bare }
    end
  end

  # GET /photo_bares/1/edit
  def edit
    @photo_bare = PhotoBare.find(params[:id])
  end

  # POST /photo_bares
  # POST /photo_bares.xml
  def create
    @photo_bare = PhotoBare.new(params[:photo_bare])

    respond_to do |format|
      if @photo_bare.save
        flash[:notice] = 'PhotoBare was successfully created.'
        format.html { redirect_to(@photo_bare) }
        format.xml  { render :xml => @photo_bare, :status => :created, :location => @photo_bare }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_bare.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_bares/1
  # PUT /photo_bares/1.xml
  def update
    @photo_bare = PhotoBare.find(params[:id])

    respond_to do |format|
      if @photo_bare.update_attributes(params[:photo_bare])
        flash[:notice] = 'PhotoBare was successfully updated.'
        format.html { redirect_to(@photo_bare) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_bare.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_bares/1
  # DELETE /photo_bares/1.xml
  def destroy
    @photo_bare = PhotoBare.find(params[:id])
    @photo_bare.destroy

    respond_to do |format|
      format.html { redirect_to(photo_bares_url) }
      format.xml  { head :ok }
    end
  end
end
