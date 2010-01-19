module HtmlFormatting
  protected
  
  include ActionView::Helpers::UrlHelper
  
  def format_attributes
    self.class.formatted_attributes.each do |attr|
      raw = read_attribute attr

      text = format_textile(raw)
      text = format_usernames(text)
      text = format_links(text)
      
      write_attribute "#{attr}_html", white_list_sanitizer.sanitize(text)
    end
  end
  
  # Get @username, like in Twitter, and link it to user path
  def format_usernames(text)
    text.gsub(/([\s>])@([a-z0-9_]+)([\W])/i) do |match|
      user = User.find_by_login(match[2..-2])
      if user && is_in_project?(user)
        if is_a? Comment
          @mentioned ||= []
          @mentioned |= [user]
        end
        match[0,2] + link_to(user.login, "/users/#{user.login}") + match[-1,1]
      else
        match
      end
    end
  end
  
  def is_in_project?(user)
     Person.exists?(:user_id => user.id, :project_id => project.id)
  end
  
  def format_textile(text)
    textilized = RedCloth.new(text, [:hard_breaks, :no_span_caps])
    textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
    textilized.to_html
  end
  
  def format_links(text)
    linked = auto_link(text) { |text| truncate(text, :length => 40) }
    linked.gsub(/href=\"www/i) { |s| "href=\"http://www" }
  end
  
end