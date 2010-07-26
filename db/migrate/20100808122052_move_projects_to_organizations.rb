class MoveProjectsToOrganizations < ActiveRecord::Migration
  def self.up
    organization_for_group = {}
    organization_for_user = {}
    Project.find_each(:batch_size => 500) do |project|
      if project.group
        # Project in a group (migration from groups to companies)
        if org_id = organization_for_group[project.group.id]
          organization = Organization.find(org_id)
        else
          organization = Organization.create!(:name => project.group.name, :permalink => project.group.permalink)
          organization_for_group[project.group.id] = organization.id
          project.group.users.each { |user| organization.add_member(user) }
        end
      else
        # Project just belongs to a user (we must create a company)
        if org_id = organization_for_user[project.user.id]
          organization = Organization.find(org_id)
        else
          permalink = Organization.find_by_permalink(project.user.login) ? "user-#{login}" : project.user.login
          organization = Organization.create!(:name => "Projects from #{project.user}", :permalink => permalink)
          organization_for_user[project.user.id] = organization.id
          organization.add_member(project.user)
        end
      end
      organization.add_project(project)
    end
    puts "going up"
  end

  def self.down
    Project.find_each(:batch_size => 500) do |project|
      project.update_attribute :organization_id, nil
    end
    Organization.destroy_all
    
    puts "going down"
  end
end
