class String
  # adapted from http://fightingforalostcause.net/misc/2006/compare-email-regex.php
  EmailLocal  = /[\w!#\$%&'*\/=?^`{|}~+-]/
  EmailDomain = /(?:(?:(?:[a-z0-9][a-z0-9-]{0,62}[a-z0-9])|[a-z])\.)+[a-z]{2,6}/i
  EmailHost   = /(?:\d{1,3}\.){3}\d{1,3}(?:\:\d{1,5})?/
  EmailRegex  = /[a-z0-9~]\.?(?:#{EmailLocal}+\.)*#{EmailLocal}*@(?:#{EmailDomain}|#{EmailHost})/i

  # Returns an Array with all the valid emails found in String
  # Examples:
  #   "pablo@teambox.com"                #=> ["pablo@teambox.com"]
  #   "invalid@email"                    #=> []
  #   "  c@c.com word d@d.com\ne@f.com"  #=> ["c@c.com", "d@d.com", "e@f.com"]
  def extract_emails
    scan(EmailRegex)
  end

  def extract_emails!
    gsub!(EmailRegex).to_a
  end
end

