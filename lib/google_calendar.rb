require 'oauth'
require 'multi_json'

module OAuth
  class AccessToken
    def request(http_method, path, *arguments)
      # Rails.logger.debug "[GCal] Request: #{http_method}, #{path}, #{arguments.inspect}"
      super
    end
  end
end 

class GoogleCalendar
  # TODO: The calendar and event classes share a lot of common code that could be dryed up
  # TODO: The format_keys! method could probably be injected into the hash? It should also be multilevel not just operating on the top layer
  
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
    :list_all => 'https://www.google.com/calendar/feeds/default/allcalendars/full',
    :list_own => 'https://www.google.com/calendar/feeds/default/owncalendars/full',
    :event_feed => 'https://www.google.com/calendar/feeds/%name%/private/full',
    :event => 'https://www.google.com/calendar/feeds/%calendar%/private/full/%name%',
    :create_entry => 'https://www.google.com/calendar/feeds/%name%/private/full',
    :create_calendar => 'https://www.google.com/calendar/feeds/default/owncalendars/full'
  }
  HEADERS = {'GData-Version' => '2.0'}
  
  class Calendar
    FIELDS = :id, :title, :description, :location, :color, :hidden, :time_zone
    attr_accessor *FIELDS
    
    FIELDS.each do |field|
      define_method(field) do
        return @hash[field.to_s.camelize(:lower)]
      end
      
      define_method("#{field}=") do |value|
        return @hash[field.to_s.camelize(:lower)] = value
      end
    end
    
    def initialize(options={})
      @hash = options
      format_keys!
    end
    
    def url_token
      return nil if @hash['id'].nil? && @hash[:id].nil?
      (@hash['id'] || @hash[:id]).split('/')[-1]
    end
    
    def self.from_json_hash(json_hash)
      Calendar.new(json_hash)
    end
    
    def as_json(options={})
      @hash
    end
    
    protected
      def format_keys!
        @hash.keys.each do |key|
          @hash[key.to_s.camelize(:lower)] = @hash.delete(key)
        end
        @hash
      end
  end
  
  class Event
    FIELDS = :id, :title, :details, :location, :transparency, :status, :when, :self_link
    
    FIELDS.each do |field|
      define_method(field) do
        return @hash[field.to_s.camelize(:lower)]
      end
      
      define_method("#{field}=") do |value|
        return @hash[field.to_s.camelize(:lower)] = value
      end
    end
    
    # Creates a new event from the options passed in. Passing start and end will set a single occurance (overriding anything passed to when).
    # In order to create an all day event you should pass a Date only and not a DateTime or Time.
    def initialize(options={})
      start_val = options.delete(:start) || options.delete('start')
      end_val = options.delete(:end) || options.delete('end')
      options['when'] = [{'start' => start_val, 'end' => end_val}] if start_val || end_val
      
      @hash = options
      format_keys!
    end
    
    # Convenience method to get the first start date
    def start
      value = @hash['when'].try(:first).try(:[], 'start')
      return nil if value.nil?
      return value if value.is_a?(DateTime) || value.is_a?(Date)
      
      parse_date(value)
    end
    
    # Convenience method to create the first start date - this doesn't check for existing dates and will simply overwrite them
    def start=(value)
      @hash['when'] = [{'start' => value, 'end' => self.end}]
    end
    
    # Convenience method to get the first start date
    def end
      value = @hash['when'].try(:first).try(:[], 'end')
      return nil if value.nil?
      return value if value.is_a?(DateTime) || value.is_a?(Date)
      
      parse_date(value)
    end
    
    # Convenience method to create the first start date - this doesn't check for existing dates and will simply overwrite them
    def end=(value)
      @hash['when'] = [{'start' => start, 'end' => value}]
    end
    
    def url_token
      return nil if @hash['id'].nil? && @hash[:id].nil?
      (@hash['id'] || @hash[:id]).split('/')[-1]
    end
    
    def self.from_json_hash(json_hash)
      Event.new(json_hash)
    end
    
    def as_json(options={})
      @hash
    end
    
    def [](value)
      @hash[value]
    end

    protected
      def format_keys!
        @hash.keys.each do |key|
          @hash[key.to_s.camelize(:lower)] = @hash.delete(key)
        end
        @hash
      end
      
      # The parse date method will detect if a date string is an instance of a date or date with time and create the respective method
      def parse_date(value)
        raise "Dates should be strings for Google Calendar events" unless value.is_a?(String)
        
        value =~ /^\d{4}-\d{1,2}-\d{1,2}$/ ? Date.parse(value) : DateTime.parse(value)
      end
  end
  
  def initialize(access_token, access_secret, consumer)
    @consumer = consumer
    @access_token = OAuth::AccessToken.new(@consumer, access_token, access_secret)
  end
  
  def list_all(options = {})
    body = get(RESOURCES[:list_all], options)
    parse_calendars(body)
  end
  
  def list_own(options = {})
    body = get(RESOURCES[:list_own], options)
    parse_calendars(body)
  end
  
  def find(url_token, options = {})
    body = get("#{RESOURCES[:list_all]}/#{url_token}")
    Event.from_json_hash(MultiJson.decode(body)['data'])
  end
  
  def event_feed(url_token, options = {})
    body = get(RESOURCES[:event_feed].gsub('%name%', url_token))
    parse_entries(body)
  end
  
  def find_event(calendar_url_token, id, options = {})
    body = get(RESOURCES[:event].gsub('%name%', id).gsub('%calendar%', calendar_url_token))
    Event.from_json_hash(MultiJson.decode(body)['data'])
  end
  
  def create_calendar(calendar)
    body = post(RESOURCES[:create_calendar], self.class.create_post_data(calendar))
    Calendar.from_json_hash(MultiJson.decode(body)['data'])
  end
  
  def create_event(url_token, event)
    body = post(RESOURCES[:create_entry].gsub('%name%', url_token), self.class.create_post_data(event))
    Event.from_json_hash(MultiJson.decode(body)['data'])
  end
  
  def update_event(event)
    body = put(event.self_link, self.class.create_post_data(event, nil))
    Event.from_json_hash(MultiJson.decode(body)['data'])
  end
  
  def delete_event(event)
    delete(event.self_link, {}, 'If-Match' => '*')
  end
  
  protected
    def create_url(url, options = {})
      params = options.select{|k, v| !v.nil? }.map{|k, v| "#{k}=#{CGI::escape(v)}"}.join("&")
      params.blank? ? "#{url}?alt=jsonc" : "#{url}?alt=jsonc&#{params}"
    end
    
    def get(url, options = {}, headers = {}, redirects = 0)
      request(:get, url, nil, headers, options, redirects)
    end
    
    def delete(url, options = {}, headers = {}, redirects = 0)
      request(:delete, url, nil, headers, options, redirects)
    end
    
    def post(url, body, options = {}, headers = {}, redirects = 0)
      request(:post, url, body, headers, options, redirects)
    end
    
    def put(url, body, options = {}, headers = {}, redirects = 0)
      request(:put, url, body, headers, options, redirects)
    end
    
    def request(method, url, body=nil, headers={}, options = {}, redirects = 0)
      url = create_url(url, options) unless redirects > 0
      
      Rails.logger.info("[GCal] #{method} URL: #{url}")
      # Rails.logger.debug(body)
      case method
      when :post, :put
        *args = url, body, HEADERS.merge(headers).merge('Content-Type' => 'application/json')
      when :get, :delete
        *args = url, HEADERS.merge(headers).merge('Content-Type' => 'application/json')
      end
      res = @access_token.send(method, *args)
      
      Rails.logger.info "[GCal] Response: #{res.code}" ##{res.body}"
      case res.code.to_i
      when 200, 201
        return res.body
      when 301, 302
        raise StandardError.new("Too many redirects when calling #{url}") if redirects > 3
        new_url = res['location']
        Rails.logger.info "Redirecting to #{new_url} - redirects #{redirects}"
        return request(method, new_url, body, headers, options, redirects + 1)
      else
        raise RetrievalError.new(res)
      end
    end
    
    def self.create_post_data(content, version = '2.6')
      # {'apiVersion' => '1.0', :data => content}.to_json
      "{\"apiVersion\":\"#{version}\", \"data\":#{content.to_json}}"
    end
    
    def parse_calendars(body)
      details = MultiJson.decode(body)['data']['items']
      details.map do |calendar|      
        Calendar.from_json_hash(calendar)
      end
    end
    
    def parse_entries(body)
      details = MultiJson.decode(body)['data']['items']
      details.map do |entry|
        Event.from_json_hash(entry)
      end
    end
end