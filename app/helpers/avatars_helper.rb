module AvatarsHelper

  def thumb_avatar(user, round_corners = true)
    render :partial => 'avatars/thumb_avatar', 
      :locals => { :user => user, :round_corners => round_corners }
  end

  def micro_avatar(user)
    render :partial => 'avatars/micro_avatar', 
      :locals => { :user => user }
  end
  
  def avatar_path_with_timestamp(user)
    if user.avatar
      thumb_user_avatar_path(user) + "?#{user.avatar.updated_at.to_i}"
    else
      thumb_user_avatar_path(user)
    end
  end
  
end
