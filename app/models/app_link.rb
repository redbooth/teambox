class AppLink < ActiveRecord::Base

  belongs_to :user
  validates_uniqueness_of :app_user_id, :scope => :provider
  validates_uniqueness_of :user_id, :scope => :provider, :allow_nil => true

  serialize :custom_attributes
  serialize :credentials

  attr_accessible :provider, :app_user_id, :custom_attributes, :credentials, :user_id

  concerned_with :conversions

  def self.find_or_create_or_update_from_authentification(provider, auth_hash, current_user=nil)
    # Scope provider
    app_link = self.where(:provider => provider)

    # Try to match app_link first
    if current_user
      # If logged in, look inside his own account
      app_link = app_link.where(:user_id => current_user.id).first
      app_link ||= self.where(:provider => provider, :app_user_id => auth_hash.uid).first
      # We found something for this user
      if app_link
        # The user in trying to link a second account
        # or the user is trying to link an account already linked with another user
        return app_link unless app_link.app_user_id == auth_hash.uid or
               app_link.user == current_user or app_link.user.nil?
        # Make sure the account is linked with current_user
        app_link.user ||= current_user
      end
    else
      # The user is trying to login or signup, look for this UID
      app_link = app_link.where(:app_user_id => auth_hash.uid).first
    end

    # If no app link is found we create one
    app_link ||= self.new(:provider => provider, :app_user_id => auth_hash.uid, :user => current_user)

    # Update attribute everytime we can
    app_link.user = current_user if current_user and app_link.user.nil?
    app_link.custom_attributes = auth_hash.to_hash
    app_link.credentials = auth_hash.credentials.to_hash if auth_hash.credentials

    app_link.save!
    app_link
  end

  def sign_up_conflict?
    if email = detect_custom_attribute {|k,v| k == 'email' }
      return true if User.where(:email => email).count == 1
    end

    if login = detect_custom_attribute  {|k,v| /(login|username|nickname)/.match(k) }
      return true if User.where(:login => login).count == 1
    end

    false
  end

  def detect_custom_attribute(&block)
    resursive_detect custom_attributes, &block
  end

  def references
    { :users => [user_id] }
  end

  protected

  # Recursive search for key in a hash
  #
  # test = {"user"=>{"name"=>{"first_name"=>"charles"}}}
  # search_for_key(test) { |k,v| k == 'first_name' } #=> "charles"
  def resursive_detect(hash, &block)
    stack = [ hash ]

    while perform = stack.pop
      perform.each do |k, v|
        if v.is_a? Hash
          stack << v
          next
        end

        if yield k,v
          return v
        end
      end
    end
  end
end
