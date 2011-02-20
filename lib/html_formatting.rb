require 'set'

module HtmlFormatting
  attr_accessor :formatted_attributes

  def formats_attributes(*attributes)
    self.formatted_attributes ||= []
    formatted_attributes.concat attributes
    
    # TODO: learn how to deal without view helpers in models
    include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
    include InstanceMethods
    
    before_save :format_attributes
  end
  
  module InstanceMethods
    attr_reader :mentioned
    
    protected
    
    def format_attributes
      self.class.formatted_attributes.each do |attr|
        text = self[attr]

        self["#{attr}_html"] = if text.blank?
          nil
        else
          text = format_image(text)
          text = format_markdown_links(text)
          text = format_gfm(text)
          text = format_text(text)
          text = format_usernames(text)
          text = HTML::WhiteListSanitizer.new.sanitize(text)
          text = format_youtube(text)
          text = format_links(text)
        end
      end
    end

    # Get @username, like in Twitter, and link it to user path
    def format_usernames(body)
      all_mentioned = false
      
      body.gsub(/(^|\W)@(\w+)/) do |text|
        first = $1
        name = $2.downcase

        if 'all' == name
          @mentioned = project.users.confirmed
          all_mentioned = true
          first + content_tag(:span, '@all', :class => "mention")
        elsif user = project.users.confirmed.find_by_login(name)
          if not all_mentioned and Comment === self
            @mentioned ||= Set.new
            @mentioned << user
          end
          first + link_to("@#{user.login}", "/users/#{user.login}", :class => 'mention')
        else
          text
        end
      end
    end
    
    MarkdownLink = /(\[((?:\[[^\]]*\]|[^\[\]])*)\]\([ \t]*()<?(.*?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/
    WebDomain    = /^(?:(?:(?:[a-z0-9][a-z0-9-]{0,62}[a-z0-9])|[a-z])\.)+[a-z]{2,6}/i

    def format_markdown_links(body)
      body.gsub(MarkdownLink) do |text|
        anchor  = $2
        link_id = $3
        url     = $4
        title   = $7
        if $4 =~ WebDomain
          "[#{anchor}](http://#{url})"
        else
          text
        end
      end
    end

    def format_text(text)
      RDiscount.new(text).to_html
    end

    def format_links(text)
      auto_link(text) { |text| truncate(text, :length => 80) }
    end

    # Github Flavoured Markdown, from http://github.github.com/github-flavored-markdown/
    def format_gfm(text)
      # Extract pre blocks
      extractions = {}
      text.gsub!(%r{<pre>.*?</pre>}m) do |match|
        md5 = Digest::MD5.hexdigest(match)
        extractions[md5] = match
        "{gfm-extraction-#{md5}}"
      end

      # prevent foo_bar_baz from ending up with an italic word in the middle
      text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x|
        x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
      end

      # in very clear cases, let newlines become <br /> tags
      text.gsub!(/^[\w\<][^\n]*\n+/) do |x|
        x =~ /\n{2}/ ? x : (x.strip!; x << "  \n")
      end

      # Insert pre block extractions
      text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
        "\n\n" + extractions[$1]
      end

      text
    end

    YoutubeLink = /([^\"]|\A)http:\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w-]+)(&(amp;)?(?:[\w\?=-]|\+)*)?([^\"]|\z)/
    def format_youtube(text)
      text.gsub(YoutubeLink) do |link|
        "#{$1}<iframe class=\"youtube-player\" type=\"text/html\" width=\"480\" height=\"385\" src=\"http://www.youtube.com/embed/#{$2}\" frameborder=\"0\"></iframe>#{$5}"
      end
    end
    
    ImageLink = /(^https?:\/\/[^\s]+\.(?:gif|png|jpeg|jpg)(\?)*(\d+)*$)/i;
    def format_image(text)
      text.gsub(ImageLink) do |link|
        "<a href=\"#{$1}\"><img class=\"comment-image\" src=\"#{$1}\" frameborder=\"0\" alt=\"#{$1}\"/></a>"
      end
    end

  end
end
