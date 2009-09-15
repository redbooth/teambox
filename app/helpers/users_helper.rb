module UsersHelper

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

  def user_checkbox(user)
    text = ''
    text << check_box_tag("user_#{user.id}", :value => '1', :checked => true) 
    text << ' '
    text << label_tag("user_#{user.id}", user.name)
  end
    
end
