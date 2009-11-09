class UserMailer < ActionMailer::Base
  default_url_options = {:host => 'example.com'}
  def signup(email, name)
    @recipients  = email
    @from        = "admin@example.com"
    @subject     = "Account confirmation"
    @sent_on     = Time.now
    @body[:name] = name
  end

  def newsletter(email, name)
    @recipients  = email
    @from        = "admin@example.com"
    @subject     = "Newsletter sent"
    @sent_on     = Time.now
    @body[:name] = name
  end
end
