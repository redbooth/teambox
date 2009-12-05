class Project

  def owner?(u)
    user == u
  end

  def admin?(user)
    if p = people.find_by_user_id(user.id)
      p.role == 3 || p.owner?
    else
      false  
    end
  end
  
  def observer?(user)
    if p = people.find_by_user_id(user.id)
      p.role == 0 && !p.owner?
    else
      false
    end
  end
  
  def editable?(user)
    if p = people.find_by_user_id(user.id)
      p.owner? || p.role > 1
    else
      false
    end
  end

end