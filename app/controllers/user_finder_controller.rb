class UserFinderController < ActionController::Base

  # If I search for an email
  #   - return the user with that email, if found
  #   - return [] if there is no user with that email
  # If I search for text
  #   - return at most 3 partial matches of users, sorted by the most active
  #   - return [] if there are no matches
  # Minimum search should be 3 characters, error if not
  # THOUGHT: Unify email and text search?
  # TODO: Spam prevention
  def find
    terms = (params[:q] || '').strip

    emails = terms.extract_emails
    users = if emails.any?
      User.where(:email => emails[0,5])
    else
      if terms.length < 3
        []
      else
        # TODO: Replace for Sphinx and look for first and last name too
        User.where(["login LIKE ? OR first_name LIKE ? OR last_name LIKE ?", terms,terms,terms]).limit(3).order("visited_at DESC")
      end
    end
    render :json => shortened_user_profiles(users)
  end

  private

    def shortened_user_profiles(users)
      Array(users).collect do |user|
        {
          :id => user.id,
          :username => user.login,
          :first_name => user.first_name,
          :last_name => user.last_name,
          :thumb_avatar_path => user.avatar_or_gravatar_path(:thumb),
          :micro_avatar_path => user.avatar_or_gravatar_path(:micro),
          :projects => user.people.collect do |person|
            { :role => person.role,
              :id => person.project_id }
          end,
          :organizations => user.memberships.collect do |member|
            { :role => member.role,
              :id => member.organization_id }
          end
        }
      end
    end

end
