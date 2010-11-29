class GoogleDocs
  class ConfigurationError; end
  class RetrievalError < StandardError
    attr_accessor :response
    
    def initialize(response)
      @response = response
      super("Response returned: #{response.code} #{response.message}")
    end
  end
  
  RESOURCES = {
    :scope => 'https://docs.google.com/feeds/',
    :request_token_url => 'https://www.google.com/accounts/OAuthGetRequestToken',
    :access_token_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
    :authorize_url => "https://www.google.com/accounts/OAuthAuthorizeToken",
    :list => 'https://docs.google.com/feeds/default/private/full?showfolders=true',
    :create => 'https://docs.google.com/feeds/default/private/full'
  }
  
  TYPES = %w{document drawing file pdf presentation spreadsheet} # folder removed
  HEADERS = {'GData-Version' => '3.0'}
  
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
  
  def create(options)
    options.assert_valid_keys('title', 'document_type', 'x')
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
  
  protected
    def parse_list(data)
      docs = []
      document = Nokogiri::XML(data)
      document.xpath("//atom:entry", "atom" => "http://www.w3.org/2005/Atom").each do |entry|
        doc = parse_entry(entry)
        docs << doc
      end
      docs
    end
    
    def create_url(url, options)
      params = options.select{|k, v| !v.nil? }.map{|k, v| "#{k}=#{v}"}.join("&")
      puts params
      params.blank? ? url : "#{url}?#{params}"
    end
  
    def parse_entry(entry)
      doc = {}
      doc[:document_type], doc[:document_id] = entry.xpath("./gd:resourceId", "gd" => "http://schemas.google.com/g/2005").text.split(':')
      doc[:title] = entry.xpath("./atom:title/text()", "atom" => "http://www.w3.org/2005/Atom").first.text
      doc[:url] = entry.xpath("./atom:link[@rel='alternate']", "atom" => "http://www.w3.org/2005/Atom").first["href"]
      doc[:edit_url] = entry.xpath("./atom:link[@rel='edit']", "atom" => "http://www.w3.org/2005/Atom").first["href"]
      doc[:acl_url] = entry.xpath("./gd:feedLink[@rel='http://schemas.google.com/acl/2007#accessControlList']","gd" => "http://schemas.google.com/g/2005").first["href"]
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
end