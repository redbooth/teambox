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
    else
      raise exception
    end
  end
  
  # TODO: Allow users to add an existing fileserver (bucket) as the bucket for their organization
  # TODO: Auto add a bucket when an admin signs up for a nomadesk account???
  # TODO: Make sure only admins can create a Nomadesk bucket
  
  def index
    if @organization.settings['nomadesk'] && @organization.settings['nomadesk']['bucket_name']
      @bucket = @nomadesk.get_bucket(@organization.settings['nomadesk']['bucket_name'])
      @files = @nomadesk.list(@bucket, @path)
    else
      # No bucket stored for the organisation redirect to new
      # render :bucket_missing
      redirect_to storage_options_organization_path(@organization)
    end
  end
  
  def create_bucket
    if @organization.settings['nomadesk'] && @organization.settings['nomadesk']['bucket_name']
      render :text => "Bucket already exists for organization (#{@organization.settings['nomadesk']['bucket_name']})"
    else
      title = "teambox-#{@organization.name.parameterize}-#{rand(1000)}"
      bucket = @nomadesk.create_bucket(title)
      
      @organization.settings = {'nomadesk' => {'bucket_name' => bucket.name, 'created_by' => current_user.id}}
      @organization.save!
      
      flash[:notice] = "Bucket #{title} created"
      redirect_to :back
    end
  end
  
  def create_account
    email = current_user.email
    
    begin
      @nomadesk = Nomadesk.create_account(
        :host => NOMADESK_HOST,
        :email => email,
        :password => params[:nomadesk][:password],
        :first_name => current_user.first_name,
        :last_name => current_user.last_name,
        :phone => '0000000000',
        :skip_confirm => 'true'
      )
      
      current_user.update_attributes!(:nomadesk_password => params[:nomadesk][:password])
      flash[:notice] = "Account created"
    rescue Nomadesk::ResponseError => e
      flash[:error] = e.response_message
    end
    
    redirect_to :back
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
      begin
        creator = User.find(@organization.settings['nomadesk']['created_by'])
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
      if current_user.nomadesk_email && !current_user.nomadesk_password.blank?
        @nomadesk = Nomadesk.new(:host => NOMADESK_HOST, :user => current_user.nomadesk_email, :pass => current_user.nomadesk_password)
      else
        render :account_missing
        return false
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
