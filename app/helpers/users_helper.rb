module UsersHelper
  def user_fields(f)
    render :partial => 'users/fields', :locals => { :f => f }
  end

end
