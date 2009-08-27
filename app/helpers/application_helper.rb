# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def header
    render :partial => 'shared/header'
  end

  def project_navigation(project)
    render :partial => 'shared/project_navigation',
      :locals => { :project => project }
  end
  
  def navigation(project,recent_projects)
    render :partial => 'shared/navigation',
      :locals => { 
        :project => project, 
        :recent_projects => recent_projects }
  end

  def global_navigation
    render :partial => 'shared/global_navigation'
  end
  
  def footer
    render :partial => 'shared/footer'
  end

  def location_name?(names)
    names.any?{ |name| name == location_name }
  end
    
  def location_name
    "#{action_name}_#{controller.controller_name}"
  end
   
  def ef(e)
    page << "if($('#{e}')){"
  end

  def esf(e)
    page << "}else if($('#{e}')){"
  end

  def els
    page << "}else{"
  end

  def en
    page << "}"
  end

  def loading(action,id=nil)
    if id.nil?
      image_tag('loading.gif', :id => "#{action}_loading", :style => 'display: none')
    else  
      image_tag('loading.gif', :id => "#{action}_loading_#{id}", :style => 'display: none')
    end
  end
  
  def trash_image(size='24x24')
    image_tag('trash.gif', :class => 'trash', :size => size)
  end

  def pencil_image(size='24x24')
    image_tag('pencil.gif', :class => 'pencil', :size => size)
  end

  def reload_javascript_events
      page << "Event.addBehavior.reload()"
  end
    
end