class Nomadesk
  class Token
    attr_accessor :key
    
    def initialize(key)
      @key = key
      self
    end
    
    def self.from_login(username, password, host = nil)
      options = {:user => username, :pass => password, :params => { "Task" => "Logon" }}
      options[:host] = host unless host.nil?
      
      res = Request.get!(options)
      key = res['Token']
      Token.new(key)
    end
  end
  
  class ResponseError < StandardError
    attr_accessor :status, :response_message
    
    def initialize(res, message="")
      @status = res.status.to_i
      @response_message = res.message
      super("Nomadesk::ResponseError #{res.message} (#{res.status}) #{message}")
    end
  end
  
  class Response
    attr_reader :hash, :status, :message, :raw
    
    def initialize(xml)
      @raw = xml
      @hash = Hash.from_xml(xml)['Response']
      @status = @hash.delete('Status')
      @message = @hash.delete('Message')
      puts @raw
      
      self
    end
    
    def [](key)
      return @hash[key]
    end
  end
  
  class Request
    DEFAULT_HOST = 'secure.nomadesk.com'
    
    def self.get(options)
      url = generate_request_url(options)
      puts url
      
      # xml = open(url).read
      
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      # TODO: This is bad (some would say very bad) but we have to do it right now as the cert isn't valid !!!
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      
      Response.new(response.body)
    end
    
    def self.get!(options)
      res = get(options)
      raise ResponseError.new(res) unless res.status == "1"
      
      res
    end
    
    def self.url_for(options)
      self.generate_request_url(options)
    end
    
    protected
      def self.generate_request_url(options)
        options[:params] ||= {}
        
        if options[:url]
          base = options[:url]
        else
          options[:protocol] ||= "https"
          options[:host]     ||= DEFAULT_HOST
          options[:path]     ||= "/nomadesk-ctrller/api.php"
          base = "#{options[:protocol]}://#{options[:host]}#{options[:path]}"
        end
        
        options[:params]['Task'] = options[:task] if options[:task]

        if options[:token] && options[:token].is_a?(Token)
          options[:params]["Token"] = options[:token].key
        elsif options[:user] && (options[:pass] || options[:password])
          options[:params].merge!("Email" => options[:user], "Password" => options[:pass] || options[:password])
        else
          unless ['CreateAccount', 'SuspendAccount', 'DestroyAccount'].include?(options[:task])
            raise ArgumentError.new("No authorization params were passed")
          end
        end

        params = options[:params].collect { |k,v| "#{k}=#{v}" }.join("&")

        "#{base}?#{URI.escape params}"
      end
  end
  
  class Bucket
    attr_accessor :provider, :name, :label, :api_url
    
    def initialize(provider, name, label, storage_api_url)
      @provider = provider
      @name = name
      @label = label
      @api_url = storage_api_url
    end
    
    def self.list_from_hash(provider, hash_list)
      hash_list.map{|h| self.from_hash(provider, h) }
    end
    
    def self.from_hash(provider, hash)
      Bucket.new(provider, hash['Name'], hash['Label'], hash['StorageApiUrl'])
    end
    
    def list(path = '/')
      provider.list(self, path)
    end
    
    def invite_email(email, *args)
      provider.invite_email(self.name, email, *args)
    end
  end
  
  class Item
    attr_accessor :provider, :bucket, :name, :path, :item_type, :modified, :size
    
    def initialize(provider, bucket, name, path, item_type, size, modified)
      @provider = provider
      @bucket = bucket
      @name = name
      @path = path
      @item_type = item_type
      @size = size
      @modified = modified
    end
    
    def is_folder?
      return item_type == 'folder'
    end
    
    def full_path
      return "#{path}#{name}"
    end
    
    def download_url
      @provider.download_url(@bucket, self.full_path)
    end
    
    def download_compressed_url
      @provider.download_compressed_url(@bucket, self.full_path)
    end
    
    def delete_url
      @provider.delete_url(@bucket, self.full_path)
    end
    
    def self.list_from_hash(provider, bucket, hash_list)
      hash_list.map{|h| self.from_hash(provider, bucket, h) }
    end
    
    def to_param
      self.full_path
    end
    
    def delete
      @provider.delete(@bucket, self.full_path)
    end
    
    def self.from_hash(provider, bucket, hash)
      item = Item.new(
        provider,
        bucket,
        hash['Name'],
        hash['Path'],
        hash['IsFolder'] == "true" ? 'folder' : hash['Type'],
        hash['Size'].to_i,
        Time.at(hash['LastModifiedDstamp'].to_i)
      )
    end
  end
  
  PERMISSIONS = [:shared, :private]
  ACCESS_TYPES = [:read_only, :read_write]
  
  attr_accessor :host
  
  def initialize(options)
    if options[:user] && (options[:pass] || options[:password])
      @user = options[:user]
      @pass = options[:pass] || options[:password]
    elsif options[:token]
      @token = Token.new(options[:token])
    else
      raise ArgumentError.new("You must supply the :user and :pass or :token parameters to Nomadesk")
    end
    
    @host = options[:host]
  end
  
  # Creates an account and returns a token. This can then be used to create an instance of Nomadesk if requried
  def self.create_account(options)
    required_fields = [:email, :password, :first_name, :last_name, :phone]
    raise ArgumentError.new("Options must contain all required fields") unless required_fields.all?{|f| options.include?(f) }
    raise ArgumentError.new("You should pass a host to create account") unless options[:host]
    
    res = request('CreateAccount', :host => options.delete(:host), :params => format_keys(options))
    Token.new(res['Token'])
  end
  
  # This method is a reserved method and can only be used from an allowed IP
  def self.suspend_account(email, host)
    warn "Suspending account #{email} this can only be used from an allowed IP"
    res = request('SuspendAccount', :host => host, :params => {'Email' => email})
    return true
  end
  
  # This method is a reserved method and can only be used from an allowed IP
  def self.destroy_account(email, host)
    warn "Destroying account #{email} this can only be used from an allowed IP"
    res = request('DestroyAccount', :host => host, :params => {'Email' => email})
    return true
  end
  
  def token
    if @token
      @token
    else
      @token = Token.from_login(@user, @pass, @host)
    end
  end
  
  def change_password(old_password, new_password)
    res = task("ChangePassword", :params => {'OldPassword' => old_password, 'NewPassword' => new_password})
    return true
  end
  
  # skip confirm is only availible on some systems
  def change_email(email, skip_confirm = false)
    res = task("StartChangeEmailAddress", :params => {'Email' => email, 'SkipConfirm' => skip_confirm.to_s})
    return true
  end
  
  def buckets
    res = task("GetFileservers")
    list = arrayify(res['Fileservers']['Fileserver'])
    Bucket.list_from_hash(self, list)
  end
  
  def get_bucket(name)
    res = task('GetFileserverInfo', :params => {"FileserverName" => name})
    Bucket.from_hash(self, res['Fileservers']['Fileserver'])
  end
  
  def find_bucket(label)
    res = task('SearchFileserver', :params => {'Label' => label, 'Name' => ''})
    puts res
  end
  
  def list(bucket, path = '/')
    raise ArgumentError.new("Bucket must be an instance of Bucket") unless bucket.is_a?(Bucket)
    
    res = task('ls', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
    list = arrayify(res['FileInfos']['FileInfo'])
    Item.list_from_hash(self, bucket, list)
  end
  alias_method :ls, :list
  
  def create_folder(bucket, path)
    res = task('mkdir', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
    list = arrayify(res['FileInfos']['FileInfo'])
    Item.list_from_hash(self, bucket, list).first
  end
  alias_method :mkdir, :create_folder
  
  def download_url(bucket, path)
    raise ArgumentError.new("Bucket must be an instance of Bucket") unless bucket.is_a?(Bucket)
    
    task_url('FileDownload', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
  end
  
  def download_compressed_url(bucket, path)
    raise ArgumentError.new("Bucket must be an instance of Bucket") unless bucket.is_a?(Bucket)
    
    task_url('DownloadAsZip', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
  end
  
  def file_upload_url(bucket, path)
    raise ArgumentError.new("Bucket must be an instance of Bucket") unless bucket.is_a?(Bucket)
    
    task_url('FileUpload', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
  end
  
  def delete_url(bucket, path)
    res = task_url('rm', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
  end
  
  def delete(bucket, path)
    res = task('rm', :url => bucket.api_url, :params => {"FileserverName" => bucket.name, "Path" => path})
    return true
  end
  
  def create_bucket(label, permissions = :shared, read_only = nil)
    raise ArgumentError.new("Permissions must be #{PERMISSIONS.join(' or ')}") unless PERMISSIONS.include?(permissions)
    raise ArgumentError.new("Label #{label} is not valid") unless label =~ /^[a-zA-Z0-9-]+$/i
    
    params =  {'FileserverLabel' => label, 'Type' => get_type_from_permission(permissions)}
    params['ReadOnly'] = read_only unless read_only.nil?
    
    res = task('CreateFileserver', :params => params)
    Bucket.from_hash(self, res['Fileservers']['Fileserver'])
  end
  
  def delete_bucket(bucket)
    delete_bucket_by_name(bucket.name)
  end
  
  def delete_bucket_by_name(name)
    res = task('RemoveFileserver', :params => {'FileserverName' => name})
    return true
  end
  
  # This is a private API call only useful for testing
  def destroy_bucket(name)
    raise NotImplementedException.new("DestroyFileserver isn't implemented yet as it's a private API method")
    warn "Destroying bucket #{name} this can only be used from an allowed IP"
    res = task('DestroyFileserver', :params => {'FileserverName' => name} )
    return true
  end
  
  def invite_email(bucket_name, email, *args)
    invite_emails(bucket_name, [email], *args)
  end
  
  def invite_emails(bucket_name, emails, skip_confirm = false, access_type = :read_write, options={})
    raise ArgumentError.new("AccessType is invalid #{access_type}") unless ACCESS_TYPES.include?(access_type)
    
    res = task('InviteUser', :params => {
      'Emails[]' => emails.join(','),
      'FileserverName' => bucket_name,
      'SkipConfirm' => skip_confirm.to_s,
      'Access' => get_access_type(access_type),
      'AllowInvite' => 'false',
      'OpenEmail2Folder' => 'true'
      }.merge(options))
    return true
  end
  
  def remove_user(bucket_name, email)
    res = task('CancelUser', :params => {'Email' => email, 'FileserverName' => bucket_name})
    return true
  end
  
  protected
    def arrayify(object)
      case object
      when Hash then [object]
      when Array then object
      when nil then []
      else raise "Unexpected class for arrayify #{object.class}"
      end
    end
    
    def task_url(task, options)
      Request.url_for({:host => @host, :task => task, :token => token}.merge(options))
    end
    
    def task(task, options = {})
      res = Request.get!({:host => @host, :task => task, :token => token}.merge(options))
    end
    
    def self.request(task, options)
      res = Request.get!({:task => task}.merge(options))
    end
    
    def self.format_keys(hash)
      hash.inject({}) do |h, (key, value)|
        h[key.to_s.camelize] = value
        h
      end
    end
    
    def get_access_type(access_type)
      case access_type
      when :read_only
        'ReadOnly'
      when :read_write
        'ReadWrite'
      else
        raise ArgumentError.new("Unknown access_type #{permission}")
      end
    end
    
    def get_type_from_permission(permission)
      case permission
      when :shared
        'Team Fileserver'
      when :private
        'Personal Fileserver'
      else
        raise ArgumentError.new("Unknown permission #{permission}")
      end
    end
end