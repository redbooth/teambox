module TeamboxUsernames
  def each_user(usernames, factory = false)
    usernames.scan(/(?:^|\W)@(\w+)/).flatten.each do |name|
      user = User.find_by_login(name)
      
      unless user
        if factory
          user = if name == 'mislav'
            Factory.create(:mislav)
          else
            Factory.create(:user, :login => name)
          end
        else
          raise "can't find user with login '#{name}'" unless user
        end
      end
      
      yield user
    end
  end
end

World(TeamboxUsernames)