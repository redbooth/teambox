# Used for installations using ar_mailer, which is an alternative to smtp.
# ar_mailer queues emails to be sent in the background, without blocking the UI.

class Email < ActiveRecord::Base

end