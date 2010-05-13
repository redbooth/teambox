module MobileHelper
  
  def controller_selected?(controllers)
    'selected' if Array(controllers).include? controller.controller_name
  end

end