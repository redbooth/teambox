module GroupsHelper
  def groups_column
    render 'groups/column', :group => @group, :groups => current_user.groups
  end
  
  def group_icon(group)
    src = group.has_logo? ? group.logo.url(:icon) : "/images/icon_logo_black.png"
    link_to "<img class='icon' src='#{src}' alt='#{group.name}'/>", group_path(group), :class => 'icon'
  end
  
  def group_logo_fields(group, f, button=false)
    render 'groups/logo_fields', 
      :f => f, :group => group, :include_button => button
  end
  
  def group_project_form()
    render 'groups/project_form',
      :group => @group,
      :projects => @current_user.projects - @group.projects
  end
  
  def add_group_project_link
    link_to_function t('groups.show.add_project'), show_group_project_form, :id => 'group_project_link'
  end
  
  def watch_permalink_group
    javascript_tag "$('group_permalink').observe('keyup', function(e) { Group.valid_url(); })"
  end
  
  def remove_member_link(group,member,user)
    if !group.owner?(member)
      if user.id == member.id
        delete_member_link(group,member, '.leave')
      else
        delete_member_link(group,member, '.remove')
      end
    end
  end
  
  def remove_group_project_link(group, project)
    if group.admin?(current_user)
      link_to_remote t('groups.index.remove_project'), :url => projects_group_path('group[project_ids]' => project.id), :method => :delete
    end
  end
  
  def list_group_projects(group)
    render :partial => 'groups/project', :collection => group.projects, :locals => {:group => group}
  end
  
  def delete_member_link(group,member,ts)
    link_to_remote t(ts), :url => members_group_path(@group, 'group[member_ids][]' => member.id), :method => :delete
  end
  
  def show_group_project_form
    update_page do |page|
      page.show "group_project_form"
      page.hide "group_project_link"
    end
  end
  
  def hide_group_project_form
    update_page do |page|
      page.hide "group_project_form"
      page.show "group_project_link"
    end
  end
  
  def invite_by_group_search(target,invitation)
    render 'groups/search', :target => target, :invitation => invitation
  end
  
  def list_members(group, users)
    render :partial => 'member', 
      :collection => users, 
      :as => :member, :locals => {:group => group}
  end
  
  def member_header(group, user)
    render 'groups/header', :group => group, :user => user
  end
end
