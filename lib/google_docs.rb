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
    :list => 'https://docs.google.com/feeds/default/private/full'
  }
  
  def initialize(access_token, access_secret, consumer)
    @consumer = consumer
    @access_token = OAuth::AccessToken.new(@consumer, access_token, access_secret)
  end
  
  def list(options = {})
    url = create_url(RESOURCES[:list], options)
    res = @access_token.get(url, {'GData-Version' => '3.0'})
    if res.code == 200 || res.code == '200'
      return parse_list(res.body)
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
      doc[:type], doc[:id] = entry.xpath("./gd:resourceId", "gd" => "http://schemas.google.com/g/2005").text.split(':')
      doc[:title] = entry.xpath("./atom:title/text()", "atom" => "http://www.w3.org/2005/Atom").first.text
      doc[:link] = entry.xpath("./atom:link[@rel='alternate']", "atom" => "http://www.w3.org/2005/Atom").first["href"]
      doc[:edit_link] = entry.xpath("./atom:link[@rel='edit']", "atom" => "http://www.w3.org/2005/Atom").first["href"]
      doc[:acl_link] = entry.xpath("./gd:feedLink[@rel='http://schemas.google.com/acl/2007#accessControlList']","gd" => "http://schemas.google.com/g/2005").first["href"]
      doc
    end
end