class NotificationsController < ApplicationController
  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user
  before_filter :find_notification, :except => [:index, :update]

  def index
    @notifications = current_user.notifications.includes(:comment).paginate :page => params[:page]
    @subactions = %w(read unread delete)
  end

  def show
    target = @notification.target

    if notifications = current_user.notifications.where(:target => target)
      notifications.update_all(:read => true)
      update_unread_notification_count
    end

    redirect_to [target.project, target]
  end

  def destroy
    #@notification.destroy
    redirect_to :action => :index
  end

  def toggle
    @notification.toggle!(:read)
    redirect_to :action => :index
  end

  def update
    subaction = find_subaction
    flash[:notice] = subaction

    if params[:ids] and ( @notifications = current_user.notifications.where(:id => params[:ids]) ).any?

      case subaction
      when :unread   then @notifications.update_all(:read => false)
      when :read     then @notifications.update_all(:read => true)
      when :delete   then @notifications.delete_all
      when false
        flash[:error] = 'invalid request'
      end

      update_unread_notification_count
    else
      # Empty/Invalid selection
    end

    redirect_to :action => :index
  end

  def all_read
    current_user.notifications.update_all(:read => true)
    current_user.update_attribute(:unread_notifications_count, 0)
    redirect_to :action => :index
  end

  private
  
  def find_notification
    @notification =  current_user.notifications.find_by_id(params[:id])
  end
  
  def update_unread_notification_count
    current_user.update_attribute(:unread_notifications_count, current_user.unread_notifications.count)
  end

  def find_subaction
    # Has only one sub action at the time
    return false if (params.keys.size - 1) == params.keys - [:read, :unread, :unwatch, :delete]

    # Hack to use submit button name like a boolean
    if params.has_key?(:read)
      :read
    elsif params.has_key?(:unread)
      :unread
    elsif params.has_key?(:unwatch)
      :unwatch
    elsif params.has_key?(:delete)
      :delete
    else
      false
    end
  end
end
