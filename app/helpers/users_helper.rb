module UsersHelper

  def profile_completeness
    if logged_in?
      unless current_user.profile_complete?
        render :partial => 'users/profile_completeness'
      end  
    end  
  end

  def user_fields(f, user, invite = nil)
    render :partial => 'users/fields', 
      :locals => { 
        :f => f,
        :user => user,
        :invite => invite }
  end

  def edit_avatar(f,user)
    render :partial => 'edit_avatar',
      :locals => { 
        :f => f,
        :user => user }
  end

  def user_link(user)
    if user.name.blank?
      link_to h(user.login), user_path(user)
    else
      link_to h(user.name), user_path(user)
    end
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
  
  def clear_password_if_not_updated
    update_page_tag do |page|
      page['edit_user'].observe('submit') do |page|
        page << "if ($('change_password_link').visible()) {"
          page['user_password'].setValue('')
          page['user_password_confirmation'].setValue('')
        page << "}"
      end
    end
  end
  
  def user_rss_token(url)
    url + "?rss_token=#{current_user.rss_token}#{current_user.id}"
  end
end
