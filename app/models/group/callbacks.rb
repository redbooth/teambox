class Group
  def after_create
    add_user(user)
  end
end