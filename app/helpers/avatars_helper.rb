module AvatarsHelper

  def thumb_avatar(user)
    render 'avatars/thumb_avatar', :user => user
  end

  def micro_avatar(user)
    render 'avatars/micro_avatar', :user => user
  end
  
  def avatar_path_with_timestamp(user)
    if user.avatar
      thumb_user_avatar_path(user) + "?#{user.avatar.updated_at.to_i}"
    else
      thumb_user_avatar_path(user)
    end
  end
  
end
