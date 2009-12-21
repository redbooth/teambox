class Project

  def owner?(u)
    user == u
  end

  def commentable?(user)
    check_role(user,Person::ROLES[:commenter])
  end
  
  def observable?(user)
    check_role(user,Person::ROLES[:observer])
  end
  
  def editable?(user)
    check_role(user,Person::ROLES[:participant])
  end

  def admin?(user)
    check_role(user,Person::ROLES[:admin]) || self.user == user
  end

  protected
    def check_role(user,role)
      p = people.find_by_user_id(user.id) and (p.role >= role or p.owner?)
    end
end