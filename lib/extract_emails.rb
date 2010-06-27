class String
  Email_name_regex  = '[\w\.%\-]+'.freeze
  Domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  Domain_tld_regex  = '(?:[A-Z]{2,3}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|coop|museum)'.freeze
  Email_regex       = /\A#{Email_name_regex}@#{Domain_head_regex}#{Domain_tld_regex}\z/i

  # Returns an Array with all the valid emails found in String
  # Examples:
  #   "pablo@teambox.com"                #=> ["pablo@teambox.com"]
  #   "invalid@email"                    #=> []
  #   "  c@c.com word d@d.com\ne@f.com"  #=> ["c@c.com", "d@d.com", "e@f.com"]
  def extract_emails
    split(/[^\w\.%\-@\+]/).select { |email| email.match Email_regex }
  end
end