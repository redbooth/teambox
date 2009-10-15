module UsersHelper

  def profile_completeness
    if logged_in?
      unless current_user.profile_complete?
        render :partial => 'users/profile_completeness'
      end  
    end  
  end

  def conversations_first_comment_link
    link_to_remote 'First Comment', 
      :url => conversations_first_comment_user_path(current_user), 
      :method => :put, 
      :html => { :class => "#{'active' if current_user.conversations_first_comment}", :id => 'conversations_first_comment' }    
  end

  def conversations_latest_comment_link
    link_to_remote 'Lastest Comment', 
      :url => conversations_latest_comment_user_path(current_user), 
      :method => :put, 
      :html => { :class => "#{'active' unless current_user.conversations_first_comment}", :id => 'conversations_latest_comment' }
  end

  def comments_ascending_user_link
    link_to_remote 'Ascending', 
      :url => comments_ascending_user_path(current_user), 
      :method => :put, 
      :html => { :class => "#{'active' if current_user.comments_ascending}", :id => 'comments_ascending' }    
  end

  def comments_descending_user_link
    link_to_remote 'Descending', 
      :url => comments_descending_user_path(current_user), 
      :method => :put, 
      :html => { :class => "#{'active' unless current_user.comments_ascending}", :id => 'comments_descending' }
  end
  
  def user_fields(f,user)
    render :partial => 'users/fields', 
      :locals => { 
        :f => f,
        :user => user }
  end

  def edit_avatar(f,user)
    render :partial => 'edit_avatar',
      :locals => { 
        :f => f,
        :user => user }
  end

  def user_link(user)
    if user.name.blank?
      link_to user.login, user_path(user)
    else
      link_to user.name, user_path(user)
    end
  end

  def user_checkbox(user)
    text =  check_box_tag("user_#{user.id}", :value => '1', :checked => true) 
    text << ' '
    text << label_tag("user_#{user.id}", user.name)
  end

  def show_user_password_fields
    update_page do |page|
      page['change_password_link'].hide
      page['password_fields'].show
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
end
