module WatchableHelper
  
  def watch_link(project, user, target)
    action = user.watching?(target) ? :unwatch : :watch
    
    if can?(action, target)
      link_to "<span>#{t(".#{action}")}</span>".html_safe, [action, project, target],
        :id => 'watch_link', :class => 'button', :'data-method' => 'put', :'data-remote' => true
    else
      ''
    end
  end

  def people_watching(project,user,target,state = :normal)
    render :partial => 'shared/watchers', :locals => {
      :project => project,
      :user => user,
      :target => target,
      :state => state }
  end

end