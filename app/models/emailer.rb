class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs

  def welcome(person)
    I18n.locale = person.language
    @recipients = person.email
    @from = "Teambox <notifications@teamboxapp.com>"
    @subject = I18n.t("email.user.welcome", :locale => person.language)
    #@body = {:person => person, :login_url => login_url }
    content_type "text/html"
  end
  
end
