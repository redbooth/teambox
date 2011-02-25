class Project
  
  after_create :log_create, :update_user_stats
  after_destroy :remove_from_recent_projects
  after_save :remove_recent_unless_archived
  
  def remove_recent_unless_archived
    remove_from_recent_projects if archived?
  end
  
  def log_create
    add_user(user)
    log_activity(self, 'create', user_id)

    # We'll add automagically an administration membership to the creator of the first project
    if organization.memberships.count == 0 and organization.projects.count == 1
      organization.add_member(user, Membership::ROLES[:admin])
    end
  end

  private

    def remove_from_recent_projects
      users.each do |u|
        u.remove_recent_project(self)
      end
    end

    def update_user_stats
      user.increment_stat 'projects' if user
    end

end
