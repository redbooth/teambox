class EmailBounce < ActiveRecord::Base
  
  named_scope :created_today, lambda {{:conditions => ["#{self.table_name}.created_at > ?", 1.day.ago.to_s(:db)]}}
  
  def exception=(value)
    return if value.nil?
    self.exception_type = value.class.name.underscore.split('/').last
    self.exception_message = value.message
  end
  
  def self.bounced_email_today?(email)
    raise "cannot check bounced email without an email" if email.blank?
    count = created_today.count(:conditions => {:email => email})
    count > 0
  end
  
  def self.bounce_once_per_day(exception)
    if exception.kind_of?(Emailer::Incoming::Error)
      Emailer.deliver_bounce_message(exception) unless bounced_email_today?(exception.from)
      EmailBounce.create!(:email => exception.from, :exception => exception)
    end
  end
end
