class AvatarsController < ApplicationController
  # GET /avatars
  # GET /avatars.xml
  def index
    @avatars = Avatar.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @avatars }
    end
  end

  # GET /avatars/1
  # GET /avatars/1.xml
  def show
    @avatar = Avatar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @avatar }
    end
  end

  # GET /avatars/new
  # GET /avatars/new.xml
  def new
    @avatar = Avatar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @avatar }
    end
  end

  # GET /avatars/1/edit
  def edit
    @avatar = Avatar.find(params[:id])
  end

  # POST /avatars
  # POST /avatars.xml
  def create
    @avatar = Avatar.new(params[:avatar])

    respond_to do |format|
      if @avatar.save
        flash[:notice] = 'Avatar was successfully created.'
        format.html { redirect_to(@avatar) }
        format.xml  { render :xml => @avatar, :status => :created, :location => @avatar }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @avatar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /avatars/1
  # PUT /avatars/1.xml
  def update
    @avatar = Avatar.find(params[:id])

    respond_to do |format|
      if @avatar.update_attributes(params[:avatar])
        flash[:notice] = 'Avatar was successfully updated.'
        format.html { redirect_to(@avatar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @avatar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /avatars/1
  # DELETE /avatars/1.xml
  def destroy
    @avatar = Avatar.find(params[:id])
    @avatar.destroy

    respond_to do |format|
      format.html { redirect_to(avatars_url) }
      format.xml  { head :ok }
    end
  end
end
