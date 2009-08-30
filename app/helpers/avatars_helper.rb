module AvatarsHelper

  def thumb_avatar(user)
    render :partial => 'avatars/thumb_avatar', 
      :locals => { :user => user }
  end

  def micro_avatar(user)
    render :partial => 'avatars/micro_avatar', 
      :locals => { :user => user }
  end
  
end
