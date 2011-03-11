module NotificationsHelper
  
  def toggle_notification_read_status_link(notification)
    link_to t(".mark_as_#{notification.read? ? 'unread' : 'read'}"), toggle_notification_path(notification), :method => :post, :remote => true, :'data-alt' => t(".mark_as_#{notification.read? ? 'read' : 'unread'}"), :class => :toggle
  end

  def delete_notification_link(notification)
    link_to t(".delete"), notification_path(notification), :method => :delete, :class => :delete, :remote => true
  end

end