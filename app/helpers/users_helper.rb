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

    
end
