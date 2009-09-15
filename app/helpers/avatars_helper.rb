module AvatarsHelper

  def thumb_avatar(user, round_corners = true)
    render :partial => 'avatars/thumb_avatar', 
      :locals => { :user => user, :round_corners => round_corners }
  end

  def micro_avatar(user)
    render :partial => 'avatars/micro_avatar', 
      :locals => { :user => user }
  end
  
end
