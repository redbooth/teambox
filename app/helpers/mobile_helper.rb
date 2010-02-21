module MobileHelper

  def project_menu(project)
    render :partial => 'shared/project_navigation', :locals => { :project => project }
  end
  
  def controller_selected?(controllers)
    'selected' if Array(controllers).include? controller.controller_name
  end

end