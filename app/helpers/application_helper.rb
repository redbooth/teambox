# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def header
    render :partial => 'shared/header'
  end

  def project_navigation(project)
    render :partial => 'shared/project_navigation',
      :locals => { :project => project }
  end
  
  def navigation(project)
    render :partial => 'shared/navigation',
      :locals => { :project => project }
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
    
end