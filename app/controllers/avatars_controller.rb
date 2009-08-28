class AvatarsController < ApplicationController
  skip_before_filter :require_login
  before_filter :find_user, :only => [:show,:thumb,:micro,:profile,:create,:update,:destroy]
  before_filter :find_avatar, :only => [:show,:thumb,:micro,:profile,:create,:update,:destroy]
  before_filter :responds_to_jpg, :only => [:thumb,:profile]
  
    def index
      @avatars = Avatar.find(:all)
      respond_to {|f|f.html}
    end

    def micro

      respond_to {|f|f.jpg}      
    end

    def show

      @coords = {
        :x1 => @avatar.x1,
        :y1 => @avatar.y1,
        :x2 => @avatar.x2, 
        :y2 => @avatar.x2
      }.to_json

      @dimensions = {
        :crop_width => @avatar.crop_width,
        :crop_height => @avatar.crop_height
      }.to_json

      respond_to do |format|
        format.html
        format.jpg
      end
    end

    def new
      @user = User.find(params[:user_id])
      @avatar = Avatar.new

      respond_to {|f|f.html}
    end

    def edit
      @user = User.find(params[:user_id])
      @avatar = @user.avatar
    end

    def create
      @user.build_avatar(params[:avatar])
      respond_to do |format|
        if @user.save
           @user.avatar.set_width_and_height
          format.html { redirect_to edit_user_path(@user) }
        else
          format.html { render 'new' }
        end
      end
    end

    def update

      respond_to do |format|
        if @avatar.update_attributes(params[:avatar])
          format.html { redirect_to edit_user_path(params[:user_id]) }
        else
          logger.info "check avatars: #{@avatar.errors}"
          format.html { render 'edit' }
        end
      end
    end

    def destroy
      @avatar = Avatar.find(params[:id])
      @avatar.destroy

      respond_to do |format|
        format.html { redirect_to(avatars_url) }
      end
    end

  protected
    def find_avatar
      @avatar = @user.avatar
    end
  
    def find_user
      @user = User.find(params[:user_id])
    end

    def responds_to_jpg
      respond_to {|f|f.jpg}
    end
end