# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Preview email rendering by visiting the "/mail_view" path
# http://github.com/37signals/mail_view
config.middleware.use MailView::Mapper, 'Emailer::Preview'

class UselessStore
  def logger
    Rails.logger
  end
  def fetch(*args)
    yield
  end
  def read(*args) end
  def write(*args) end
  def delete(*args) end
  def increment(*args) end
  def decrement(*args) end
end

config.cache_store = UselessStore.new
