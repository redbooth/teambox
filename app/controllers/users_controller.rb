class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  before_filter :find_user, :only => [ :show ]
  
  skip_before_filter :login_required, :only => [ :new, :create ]
  skip_before_filter :load_project
  
  def index
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def show
    options = { :only => [:id, :login, :name, :language, :email, 'time-zone', 'created-at', 'updated-at'] }
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml(options) }
      format.json { render :json => @user.to_json(options) }
    end
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => :new
    end
  end
  
  def update
    @current_user.update_attributes(params[:user])
    if @current_user.save
      flash[:error] = nil
      flash[:success] = "User profile updated!"
    else
      flash[:success] = nil
      flash[:error] = "Couldn't save the updated profile. Please correct the mistakes and retry."
    end
    render :action => :edit
  end

  private
    def find_user
      @user = User.find_by_id(params[:id])
    end

end
