class ResetPasswordsController < ApplicationController
  skip_before_filter :login_required
  layout "sessions"
  def new
    @reset_password = ResetPassword.new
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @reset_password }
    end
  end

  def create
    @reset_password = ResetPassword.new(params[:reset_password])
    @reset_password.user = User.find_by_email(@reset_password.email)
    
    respond_to do |format|
      if @reset_password.save
        Emailer.deliver_forgot_password(@reset_password)
        format.html { redirect_to sent_password_path(:email => @reset_password.email) }
        #format.xml  { render :xml => @reset_password, :status => :created, :location => @password }
      else
        # use a friendlier message than standard error on missing email address
        if @reset_password.errors.on(:user)
          @reset_password.errors.clear
          flash[:error] = "We can't find a #{user_model_name} with that email. Please check the email address and try again..."
        end
        format.html { render 'new' }
        #format.xml  { render :xml => @reset_password.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reset
    begin
      @user = ResetPassword.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.current]).user
    rescue
      flash[:error] = 'The change password URL you visited is either invalid or expired.'
      redirect_to(new_password_path)
    end    
  end

  def update_after_forgetting
    @reset_password = ResetPassword.find_by_reset_code(params[:reset_code])

    respond_to do |format|
      unless @reset_password.nil?
        @user = @reset_password.user
        if @user.update_attributes(params[:user])
          @reset_password.destroy
          Emailer.deliver_reset_password(@user)
          flash[:success] = "Password was successfully updated. Please log in."
          format.html { redirect_to login_path}
        else
          format.html { render :action => :reset, :reset_code => params[:reset_code] }
        end
      else
        flash[:notice] = 'I think the link has expired. Go enter your email in and retrieve a new link'
        format.html { render :action => :new, :reset_code => params[:reset_code] }
      end  
    end
  end
  
end
