class CachedFragmentsObservers < ActiveRecord::Observer
  observe :user, :person, :organization, :membership

  def after_update(record)
    case record
    when User
      if record.login_changed? || record.first_name_changed? || record.last_name_changed?
        expire_people_fragments_for_user record
      end
    when Person
      expire_people_fragments_for_project record.project
    when Organization
      expire_json_organizations_for_organization record
    when Membership
      expire_json_organizations_for_organization record.organization
    end
  end

  def after_create(record)
    case record
    when Person
      expire_people_fragments_for_project record.project
    when Membership
      expire_json_organizations_for_organization record.organization
    end
  end

  def after_destroy(record)
    case record
    when Person
      expire_people_fragments_for_project record.project, record.user_id
    when Organization
      expire_json_organizations_for_organization record
    when Membership
      expire_json_organizations_for_organization record.organization
    end
  end

  private

  def expire_people_fragments_for_user(user)
    Rails.logger.info "FRAGMENT CACHE: Expiring people fragment for the user #{user.login}"
    user.projects.each { |p| expire_people_fragments_for_project(p) }
  end

  def expire_people_fragments_for_project(project, user_id = nil)
    Rails.logger.info "FRAGMENT CACHE: Enqueueing expire job: people fragment for the project #{project.permalink}"
    user_ids = Person.where(:project_id => project.id).select(:user_id).collect(&:user_id)
    user_ids << user_id if user_id
    user_ids.each { |user_id| Rails.cache.write "projects_people_data.#{user_id}", Person.people_data_for_user(User.find_by_id(user_id)) }
  end

  def expire_json_organizations_for_organization(organization)
    Rails.logger.info "FRAGMENT CACHE: Expiring json_organizations for organization #{organization.permalink}"
    organization.users.each { |user| Rails.cache.write "json_organizations.#{user.id}", Organization.json_organizations(user) }
  end
end

