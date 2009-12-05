class Project

  def owner?(u)
    user == u
  end

  def admin?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.role == 3 || p.owner?
    end
  end
  
  def observer?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.role == 0 && p.owner? == false
    else
      false
    end
  end
  
  def editable?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.owner? || p.role > 0
    else
      false
    end
  end

end