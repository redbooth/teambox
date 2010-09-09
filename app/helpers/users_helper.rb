module UsersHelper

  def user_page_name(user)
    content_tag :h2,
      [user.name,
      content_tag(:span,"@#{user.login}", :class => 'login')].join('')
  end

  def user_link(user)
    if user.name.blank?
      link_to h(user.login), user_path(user)
    else
      link_to h(user.name), user_path(user)
    end
  end

  def show_user_password_fields
    update_page do |page|
      page['change_password_link'].hide
      page['password_fields'].show
      page['user_password'].focus
    end
  end
  
  def user_rss_token(url, filter = nil)
    filter_param = filter.present? ? "&filter=#{filter}" : ""
    url + "?rss_token=#{current_user.rss_token}#{current_user.id}#{filter_param}"
  end
  
  def avatar_or_gravatar(user, size)
    user.avatar_or_gravatar_path(size, request.ssl?).tap do |url|
      unless url.starts_with? 'http'
        url.replace(root_url.chomp('/') + url)
      end
    end
  end
  
  def gravatar_url
    "<a href='http://gravatar.com'>Gravatar</a>"
  end
  
  def build_user_phone_number(user)
    card = user.card || user.build_card
    card.phone_numbers.build unless card.phone_numbers.any?
  end
  
  def load_javascript_user_data
    javascript_tag %(
      my_user = #{json_user}
      my_projects = #{json_people}
    )
  end

  protected

    def json_user
      current_user.to_json
    end

    def json_people
      projects = {}
      # FIXME: current_user.people should use eager loading to get projects too
      current_user.people.to_a.collect do |p|
        projects[p.project.id] = {
          :permalink => p.project.permalink,
          :role => p.role,
          :name => p.project.name }
      end
      projects.to_json
    end

end
