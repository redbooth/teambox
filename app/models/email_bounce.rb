class EmailBounce < ActiveRecord::Base
  
  scope :created_today, lambda {
    { :conditions => ["#{self.table_name}.created_at > ?", 1.day.ago] }
  }
  
  scope :with_email, lambda { |address|
    { :conditions => {:email => address} }
  }
  
  def exception=(value)
    return if value.nil?
    self.exception_type = value.class.name.underscore.split('/').last
    self.exception_message = value.message
  end
  
  def self.bounced_email_today?(email)
    created_today.with_email(email).any?
  end
  
  def self.bounce_once_per_day(exception)
    if Emailer::Incoming::Error === exception and exception.sender?
      from_email = exception.mail.from.first
      
      unless bounced_email_today?(from_email)
        Emailer.send_email :bounce_message, exception.mail.from, exception.class.name.underscore.split('/').last
        EmailBounce.create!(:email => from_email, :exception => exception)
      end
    end
  end
end
