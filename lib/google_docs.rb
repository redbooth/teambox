require 'oauth'

class GoogleDocs
  class ConfigurationError; end
  class RetrievalError < StandardError
    attr_accessor :response

    def initialize(response)
      @response = response
      super("Response returned: #{response.code} #{response.message}\r\n#{response.body}")
    end
  end

  RESOURCES = {
    :scope => 'https://docs.google.com/feeds/',
    :request_token_url => 'https://www.google.com/accounts/OAuthGetRequestToken',
    :access_token_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
    :authorize_url => "https://www.google.com/accounts/OAuthAuthorizeToken",
    :list => 'https://docs.google.com/feeds/default/private/full',
    :create => 'https://docs.google.com/feeds/default/private/full',
  }

  TYPES = %w{document drawing file pdf presentation spreadsheet} # folder removed
  TYPES_YOU_CAN_CREATE = %w{document spreadsheet presentation}
  HEADERS = {'GData-Version' => '3.0'}
  ROLES = [:reader, :writer, :owner]
  SCOPES = [:user, :group, :domain, :default]

  def initialize(access_token, access_secret, consumer)
    @consumer = consumer
    @access_token = OAuth::AccessToken.new(@consumer, access_token, access_secret)
  end

  def list(options = {})
    url = create_url(RESOURCES[:list], options)
    res = @access_token.get(url, HEADERS)

    if res.code.to_i == 200
      return parse_list(res.body)
    else
      raise RetrievalError.new(res)
    end
  end

  def acl_list(acl_url, url_options = {}, parse_options = {})
    url = create_url(acl_url, url_options)
    res = @access_token.get(url, HEADERS)

    if res.code.to_i == 200
      return parse_list(res.body, :parse_acl_entry, parse_options)
    else
      raise RetrievalError.new(res)
    end
  end

  def create(options)
    options.assert_valid_keys('title', 'document_type')
    raise(ArgumentError, "You must provide a title and document_type") if options[:title].nil? || options[:document_type].nil?

    body = generate_atom(options[:title], options[:document_type])
    res = @access_token.post(RESOURCES[:create], body, HEADERS.merge('Content-Type' => 'application/atom+xml'))

    if res.code.to_i == 201
      document = Nokogiri::XML(res.body)
      return parse_entry(document.xpath("//atom:entry", "atom" => "http://www.w3.org/2005/Atom"))
    else
      raise RetrievalError.new(res)
    end
  end

  def add_permission(acl_url, scope, scope_type = :user, role = :reader)
    raise ArgumentError, "Unexpected scope_type #{scope_type}" unless SCOPES.include?(scope_type)
    raise ArgumentError, "Unexpected role #{role}" unless ROLES.include?(role)

    body = generate_acl_atom(scope, scope_type, role)
    res = @access_token.post(acl_url, body, HEADERS.merge('Content-Type' => 'application/atom+xml'))

    if res.code.to_i == 201 # the acl entry was added
      return res
    elsif res.code.to_i == 409 # the acl entry already exists
      return false
    else
      raise RetrievalError.new(res)
    end
  end


  def change_permission(acl_url, scope, scope_type, role, etag)
    raise ArgumentError, "Unexpected scope_type #{scope_type}" unless SCOPES.include?(scope_type)
    raise ArgumentError, "Unexpected role #{role}" unless ROLES.include?(role)

    body = generate_acl_atom(scope, scope_type, role, etag)
    url = "#{acl_url}/user%3A#{scope}"

    res = @access_token.put(url, body, HEADERS.merge('Content-Type' => 'application/atom+xml'))

    if res.code.to_i == 200 # the acl entry was updated
      return res
    elsif res.code.to_i == 204 # no content
      return false
    else
      raise RetrievalError.new(res)
    end
  end

  def set_read_with_key(acl_url, role = :reader)
    body = generate_acl_with_key_atom(role)
    res = @access_token.post(acl_url, body, HEADERS.merge('Content-Type' => 'application/atom+xml'))

    if res.code.to_i == 201 || res.code.to_i == 409 # the acl entry was added
      get_access_key(acl_url)
    else
      raise RetrievalError.new(res)
    end
  end

  def update_read_with_key(acl_url, role, etag)
    url = "#{acl_url}/default"
    body = generate_acl_with_key_atom(role, etag)
    res = @access_token.put(url, body, HEADERS.merge('Content-Type' => 'application/atom+xml'))

    if res.code.to_i == 200
      get_access_key(acl_url)
    else
      raise RetrievalError.new(res)
    end
  end

  def get_access_key(acl_url)
    res = @access_token.get(acl_url, HEADERS)
    if res.code.to_i == 200
      return find_key_from_acl(res.body, 'writer') || find_key_from_acl(res.body, 'reader')
    else
      return false
    end
  end

  protected

    def parse_list(data, parse_entry_method = :parse_entry, options = {})
      entry_conditions = "[not(./gAcl:role) or ./gAcl:role[@value != 'owner' and @value != 'none']]" if options[:other_users_only]
      docs = []
      document = Nokogiri::XML(data)
      document.xpath("//atom:entry#{entry_conditions}", "atom" => "http://www.w3.org/2005/Atom", "gAcl" => "http://schemas.google.com/acl/2007").each do |entry|
        doc = self.send(parse_entry_method, entry)
        docs << doc
      end
      docs
    end

    def create_url(url, options)
      params = options.select{|k, v| !v.nil? }.map{|k, v| "#{k}=#{CGI::escape(v)}"}.join("&")
      params.blank? ? url : "#{url}?#{params}"
    end

    def parse_entry(entry)
      doc = {}
      doc[:document_type], doc[:document_id] = entry.xpath("./gd:resourceId", "gd" => "http://schemas.google.com/g/2005").text.split(':')
      doc[:title] = entry.xpath("./atom:title/text()", "atom" => "http://www.w3.org/2005/Atom").first.text
      doc[:url] = entry.xpath("./atom:link[@rel='alternate']", "atom" => "http://www.w3.org/2005/Atom").first["href"]
      edit_entry = entry.xpath("./atom:link[@rel='edit']", "atom" => "http://www.w3.org/2005/Atom")
      doc[:edit_url] = edit_entry.first ? edit_entry.first["href"] : nil
      doc[:acl_url] = entry.xpath("./gd:feedLink[@rel='http://schemas.google.com/acl/2007#accessControlList']","gd" => "http://schemas.google.com/g/2005").first["href"]
      doc
    end

    def parse_acl_entry(entry)
      doc = {}
      doc[:etag] = entry["etag"]
      doc[:role] = entry.xpath("./gAcl:role", "gAcl" => "http://schemas.google.com/acl/2007").first["value"]
      doc[:scope] = entry.xpath("./gAcl:scope", "gAcl" => "http://schemas.google.com/acl/2007").first["type"]
      if doc[:scope] == "user"
        doc[:user_email] = entry.xpath("./gAcl:scope", "gAcl" => "http://schemas.google.com/acl/2007").first["value"]
        doc[:user_name] = entry.xpath("./gAcl:scope", "gAcl" => "http://schemas.google.com/acl/2007").first["name"]
      end
      doc
    end

    def generate_atom(title, document_type)
      raise ArgumentError, "Invalid document type #{document_type}" unless TYPES.include?(document_type)

      atom = xml = Builder::XmlMarkup.new(:indent => 2)
      atom.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      atom.entry('xmlns' => "http://www.w3.org/2005/Atom", 'xmlns:docs' => "http://schemas.google.com/docs/2007") do |entry|
        entry.category(
          :scheme => "http://schemas.google.com/g/2005#kind",
          :term => "http://schemas.google.com/docs/2007##{document_type}"
        )
        entry.title(title)
      end
    end

   def generate_acl_atom(scope, scope_type, role, etag = nil)

      entry_extra = {}
      unless etag.nil?
         entry_extra['xmlns:gd'] = 'http://schemas.google.com/g/2005'
         entry_extra['gd:etag'] = etag
      end

      atom = xml = Builder::XmlMarkup.new(:indent => 2)
      atom.entry({'xmlns' => "http://www.w3.org/2005/Atom", 'xmlns:gAcl' => "http://schemas.google.com/acl/2007"}.merge(entry_extra)) do |entry|
        entry.category(
          :scheme => "http://schemas.google.com/g/2005#kind",
          :term => "http://schemas.google.com/docs/2007#accessRule"
        )
        entry.gAcl :role, :value => role.to_s
        entry.gAcl :scope, :type => scope_type.to_s, :value => scope
      end
    end

    def generate_acl_with_key_atom(role, etag = nil)

      entry_extra = {}
      unless etag.nil?
         entry_extra['xmlns:gd'] = 'http://schemas.google.com/g/2005'
         entry_extra['gd:etag'] = etag
      end

      atom = xml = Builder::XmlMarkup.new(:indent => 2)
      atom.entry({'xmlns' => "http://www.w3.org/2005/Atom", 'xmlns:gAcl' => "http://schemas.google.com/acl/2007"}.merge(entry_extra)) do |entry|
        entry.category(
          :scheme => "http://schemas.google.com/g/2005#kind",
          :term => "http://schemas.google.com/docs/2007#accessRule"
        )
        entry.gAcl :'withKey', :key => '' do |with_key|
          with_key.gAcl :role, :value => role.to_s
        end
        entry.gAcl :scope, :type => 'default'
      end
    end

    def find_key_from_acl(data, role = 'reader')
      document = Nokogiri::XML(data)

      document.xpath("//atom:entry", "atom" => "http://www.w3.org/2005/Atom").each do |entry|
        with_key = entry.xpath("./gAcl:withKey", 'xmlns:gAcl' => "http://schemas.google.com/acl/2007")
        next unless with_key.first

        found_role = with_key.xpath('./gAcl:role', 'xmlns:gAcl' => "http://schemas.google.com/acl/2007")
        next unless found_role.first && found_role.first[:value] == role

        return with_key.first[:key]
      end

      return false
    end
end
