class User
  def to_api_hash(options = {})
    base = {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :locale => locale,
      :username => login,
      :time_zone => time_zone,
      :utc_offset => utc_offset,
      :biography => biography,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :avatar_url => avatar_or_gravatar_url(:thumb)
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :email
      base[:email] = email
    end
    
    if Array(options[:include]).include? :projects
      base[:projects] = projects.map{|p| p.to_api_hash }
    end
    
    if Array(options[:include]).include? :organizations
      base[:organizations] = organizations.map{|o| o.to_api_hash }
    end
    
    base
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.user :id => id do
      xml.tag! 'first-name', first_name
      xml.tag! 'last-name', last_name
      # xml.tag! 'email', email
      xml.tag! 'locale', locale
      xml.tag! 'username', login
      xml.tag! 'time_zone', time_zone
      xml.tag! 'biography', biography
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'avatar-url', avatar_or_gravatar_url(:thumb)
    end
  end
end