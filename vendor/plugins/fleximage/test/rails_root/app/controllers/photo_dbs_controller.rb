class PhotoDbsController < ApplicationController
  # GET /photo_dbs
  # GET /photo_dbs.xml
  def index
    @photo_dbs = PhotoDb.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_dbs }
    end
  end

  # GET /photo_dbs/1
  # GET /photo_dbs/1.xml
  def show
    @photo_db = PhotoDb.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_db }
    end
  end

  # GET /photo_dbs/new
  # GET /photo_dbs/new.xml
  def new
    @photo_db = PhotoDb.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_db }
    end
  end

  # GET /photo_dbs/1/edit
  def edit
    @photo_db = PhotoDb.find(params[:id])
  end

  # POST /photo_dbs
  # POST /photo_dbs.xml
  def create
    @photo_db = PhotoDb.new(params[:photo_db])

    respond_to do |format|
      if @photo_db.save
        flash[:notice] = 'PhotoDb was successfully created.'
        format.html { redirect_to(@photo_db) }
        format.xml  { render :xml => @photo_db, :status => :created, :location => @photo_db }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_db.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_dbs/1
  # PUT /photo_dbs/1.xml
  def update
    @photo_db = PhotoDb.find(params[:id])

    respond_to do |format|
      if @photo_db.update_attributes(params[:photo_db])
        flash[:notice] = 'PhotoDb was successfully updated.'
        format.html { redirect_to(@photo_db) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_db.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_dbs/1
  # DELETE /photo_dbs/1.xml
  def destroy
    @photo_db = PhotoDb.find(params[:id])
    @photo_db.destroy

    respond_to do |format|
      format.html { redirect_to(photo_dbs_url) }
      format.xml  { head :ok }
    end
  end
end
