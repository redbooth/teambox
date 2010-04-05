module HtmlFormatting
  protected

  include ActionView::Helpers::UrlHelper

  def format_attributes
    self.class.formatted_attributes.each do |attr|
      text = self[attr]

      self["#{attr}_html"] = if text.blank?
        nil
      else
        text = format_textile(text)
        text = format_usernames(text)
        text = format_links(text)
        white_list_sanitizer.sanitize(text)
      end
    end
  end

  # Get @username, like in Twitter, and link it to user path
  def format_usernames(body)
    body.gsub(/@(\w+)/) do |text|
      name = $1.downcase
      
      if 'all' == name
        @mentioned = project.users.confirmed
        text
      elsif user = project.users.confirmed.find_by_login(name)
        if Comment === self
          @mentioned ||= []
          @mentioned |= [user]
        end
        '@' + link_to(user.login, "/users/#{user.login}")
      else
        text
      end
    end
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