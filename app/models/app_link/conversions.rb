class AppLink
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.project :id => id do
      xml.tag! 'provider', provider
      xml.tag! 'app_user_id', app_user_id
      xml.tag! 'credentials', credentials
      xml.tag! 'custom_attributes', custom_attributes
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'owner-user-id', user_id
    end
  end

  def to_api_hash(options = {})
    base = {
      :id => id,
      :provider => provider,
      :app_user_id => app_user_id,
      :custom_attributes => custom_attributes,
      :credentials => credentials,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :owner_user_id => user_id
    }

    base[:type] = self.class.to_s if options[:emit_type]

    if Array(options[:include]).include? :user
      base[:user] = {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb),
        :micro_avatar_url => user.avatar_or_gravatar_url(:micro)
      }
    end

    base
  end
end
