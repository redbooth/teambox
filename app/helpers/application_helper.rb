# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def header
    render :partial => 'shared/header'
  end

  def project_navigation
    render :partial => 'shared/project_navigation',
      :locals => { :project => project }
  end
  
  def navigation
    render :partial => 'shared/navigation'
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