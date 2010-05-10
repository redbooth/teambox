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
  
  def all_users_checkbox
    text =  check_box_tag("user_all", "1", false, :name => "user_all")
    text << ' '
    text << label_tag("user_all", t('conversations.watcher_fields.people_all'))
  end

  def user_checkbox(user)
    text =  check_box_tag("user_#{user.id}", "1", true, :name => "user[#{user.id}]") 
    text << ' '
    text << label_tag("user_#{user.id}", user.name)
  end

  def show_user_password_fields
    update_page do |page|
      page['change_password_link'].hide
      page['password_fields'].show
      page['user_password'].focus
    end
  end
  
  def user_rss_token(url)
    url + "?rss_token=#{current_user.rss_token}#{current_user.id}"
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
end
