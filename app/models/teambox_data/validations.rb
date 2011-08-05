class TeamboxData
  validate :map_must_be_known
  validate :must_be_admin_of_organization
  validates_inclusion_of :service, :in => %(teambox basecamp)

  #If we are importing projects we need to be and admin of that org. This only applies to imports
  def must_be_admin_of_organization
    if organization_id && status_name != :uploading && type_name == :import
      if !user.admin_organizations.map(&:id).include?(organization_id)
        @errors.add("organization_id", "Should be an admin")
      end
    end
  end

  #We check that we know all the users in the user map
  def map_must_be_known
    if type_name == :import and status_name == :mapping
      # All users need to be known to the owner
      users = user.users_for_user_map.map(&:login)

      user_map.each do |login,dest_login|
        #If no mapping, then just assume we want to import the bugger
        unless dest_login.blank?
          if !users.include?(dest_login.to_s.strip)
            @errors.add "user_map_#{login}", "#{dest_login} Not known to user"
          end
        end
      end
    end
  end

end
