module AvatarsHelper

  def thumb_avatar(user)
    avatar_link user, :thumb
  end

  def micro_avatar(user)
    avatar_link user, :micro
  end

  def avatar_link(user, style = :thumb)
    link_to "", user, :class => "#{style}_avatar", :style => "background: url(#{avatar_or_gravatar(user, style)}) no-repeat"
  end

end
