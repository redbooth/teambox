class Notification < ActiveRecord::Base
  belongs_to :person
  belongs_to :user
  belongs_to :comment
  belongs_to :target, :polymorphic => true

  default_scope :order => 'id DESC'
  attr_accessible :read

  before_update   :update_unread_notifications_counter
  after_destroy  :decrement_unread_notifications_counter!

  protected
  def update_unread_notifications_counter
    if read?
      decrement_unread_notifications_counter!
    else
      increment_unread_notifications_counter!
    end if read_changed?
  end
  
  def decrement_unread_notifications_counter!
    user.decrement!(:unread_notifications_count)
  end

  def increment_unread_notifications_counter!
    user.increment!(:unread_notifications_count)
  end
end