class NotificationsController < ApplicationController
  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user
  before_filter :find_notification, :except => [:index, :update]

  def index
    @subactions = %w(read unread delete)
    @filters    = %w(conversations tasks)

    @notifications = current_user.notifications.includes(:comment)

    if params[:filter] and @filters.include? params[:filter]
      @notifications = @notifications.where(:target_type => params[:filter].singularize.capitalize)
    end

    @notifications = @notifications.paginate :page => params[:page], :per_page => 5
  end

  def show
    target = @notification.target

    if notifications = current_user.notifications.where(:target_id => target.id, :target_type => target.class.to_s)
      notifications.update_all(:read => true)
      update_unread_notification_count
    end

    redirect_to [target.project, target]
  end

  def destroy
    @notification.destroy
    head :ok
  end

  def toggle
    @notification.toggle!(:read)
    head :ok
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

    redirect_to :back
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
