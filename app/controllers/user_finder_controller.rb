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
    terms = params[:q] || ''

    if terms.length < 3
      # TODO: Spec this error
      render :text => "Need at least 3 characters to search", :status => :error
      return
    end

    emails = terms.extract_emails
    users = if emails[0]
      User.find_by_email(emails[0])
    else
      # TODO: Replace for Sphinx
      User.where(["first_name LIKE ?", terms]).limit(3)
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
          :avatar => 'avatar_path',
          :projects => user.people.collect do |person|
            { :role => person.role,
              :project_id => person.project_id }
          end,
          :organizations => user.memberships.collect do |member|
            { :role => member.role,
              :organization_id => member.organization_id }
          end
        }
      end
    end

end
