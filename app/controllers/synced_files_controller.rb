class SyncedFilesController < ApplicationController
  before_filter :set_page_title
  before_filter :get_path_details, :only => [:index]
  before_filter :reload_organization
  before_filter :get_nomadesk_details, :except => [:create_account]
  
  NOMADESK_HOST = 'teambox.nomadeskdemo.com'
  
  rescue_from 'Nomadesk::ResponseError' do |exception|
    case exception.status
    when 4044 # Bucket not installed
      bucket_not_installed
    when 2003 # Missing path
      missing_path
    when 4006 # User doesn't have persmission
      missing_permission
    when 4009 # payment issue
      render :text => 'Payment issue'
    when 4039 # Address already in use
      render :text => 'This email has already signed up for syncronized files'
    else
      raise exception
    end
  end
  
  # TODO: Allow users to add an existing fileserver (bucket) as the bucket for their organization
  # TODO: Auto add a bucket when an admin signs up for a nomadesk account???
  # TODO: Make sure only admins can create a Nomadesk bucket
  
  def index
    if @organization.has_synced_files?
      bucket = @organization.synced_storage_bucket(@nomadesk)
      @files = bucket.list(@path)
    else
      # No bucket stored for the organisation redirect to new
      render 'organizations/storage_options'
      # redirect_to storage_options_organization_path(@organization)
    end
  end
  
  def create_bucket
    if @organization.has_synced_files?
      render :text => "Bucket already exists for organization (#{@organization.settings['nomadesk']['bucket_name']})"
    else
      @bucket = @organization.create_synced_storage!(@nomadesk, current_user)
      flash[:notice] = "Bucket #{@organization.bucket_name} created"
      render :bucket_created
    end
  end
  
  protected
    def bucket_not_installed
      @organization.settings = {'nomadesk' => nil}
      @organization.save!
      
      flash['notice'] = "Your Nomadesk bucket cannot be found please re-link it to your account"
      #render :bucket_missing
      redirect_to storage_options_organization_path(@organization)
    end
    
    def missing_path
      if params[:project_id] && @path =~ /^\/#{params[:project_id]}\/$/
        # If we only have the project path then we need to create a folder for this project and show the index page
        bucket = @nomadesk.get_bucket(@organization.settings['nomadesk']['bucket_name'])
        @nomadesk.mkdir(bucket, @path)
        index
        render :index
      else
        # If not the folder doesn't exist we need to show this
        render :text => "Path '#{@path}' cannot be found", :status => 404
      end
    end
    
    def missing_permission
      creator = User.find(@organization.settings['nomadesk']['created_by'])
      
      if current_user == creator
        render :text => 'You do not have permission to access the bucket you created. This could be because you have altered permissions of because the bucket has expired'
        return false
      end
      
      begin
        creator_account = Nomadesk.new(:host => NOMADESK_HOST, :user => creator.nomadesk_email, :pass => creator.nomadesk_password)
        bucket = creator_account.get_bucket(@organization.settings['nomadesk']['bucket_name'])
        # TODO: the second arg on the next line should be set to true so that we skip confirm
        bucket.invite_email(current_user.nomadesk_email, false, :read_write)
        
        index
        render :index
      rescue => e
        render :text => "Sorry for now you have to accept the invite in your inbox - there's a bug with autoconfirm"
        # TODO: re-enable the line below once authconfirm bug is sorted
        # render :text => t('synced_files.permission_missing', :creator => creator || "creator missing", :error_message => e.message), :layout => :default
      end
    end
    
    def reload_organization
      # TODO: Remove the reload organization hack
      # Reload the organization because it's marked as readonly - this is a hack
      @organization = Organization.find(@organization.id)
    end
    
    def get_nomadesk_details
      unless current_user.nomadesk_password.blank?
        @nomadesk = Nomadesk.new(:host => NOMADESK_HOST, :user => current_user.nomadesk_email, :pass => current_user.nomadesk_password)
      else
        @nomadesk = current_user.create_nomadesk_account!(NOMADESK_HOST)
      end
    end
    
    def get_path_details
      params[:path] ||= ""
      @path = "/#{params[:path]}"
      @project_path = "/#{params[:project_id]}" if params[:project_id]
      @path = "#{@project_path}#{@path}" if @project_path
      @folders = params[:path].split("/")
      @parent = (@folders[0,@folders.length-1] || []).join("/")
      raise InvalidArgument.new("Invalid path #{params[:path]}") if @path =~ /\.\.([^a-zA-Z0-9]+|$)/i
    end
end
