module RssFeedHelper
  def rss_feed(options, &block)
    xml = options.delete(:xml) || eval("xml", block.binding)
    builder_klass = options.delete(:builder) || RssFeedBuilder
    xml.instruct!
    
    options[:schema_date] ||= "2005"
    
    xml.rss :version => "2.0", :'xmlns:content' => "http://purl.org/rss/1.0/modules/content/" do
      xml.channel do
        xml.link options[:root_url] if options[:root_url]
        yield builder_klass.new(xml, self, options)
      end
    end
  end
  
  class RssFeedBuilder
    def initialize(xml, view, options = {})
      @xml, @view, @options = xml, view, options
    end
    
    # Accepts a Date or Time object and inserts it in the proper format. If nil is passed, current time in UTC is used.
    def updated(date_or_time = nil)
      @xml.pubDate((date_or_time || Time.now.utc).to_s(:rfc822))
    end
    
    def description(value)
      @xml.tag! 'description', value
    end
    
    # Creates an entry tag for a specific record and prefills the id using class and id.
    #
    # Options:
    #
    # * <tt>:published</tt>: Time first published. Defaults to the created_at attribute on the record if one such exists.
    # * <tt>:url</tt>: The URL for this entry. Defaults to the polymorphic_url for the record.
    # * <tt>:id</tt>: The ID for this entry. Defaults to "tag:#{@view.request.host},#{@options[:schema_date]}:#{record.class}/#{record.id}"
    def entry(record, options = {})
      @xml.item do
        @xml.guid(options[:id] || "tag:#{@view.request.host},#{@options[:schema_date]}:#{record.class}/#{record.id}")

        if options[:published] || (record.respond_to?(:created_at) && record.created_at)
          @xml.pubDate((options[:published] || record.created_at).to_s(:rfc822))
        end

        @xml.link options[:url] || @view.polymorphic_url(record)

        yield @xml
      end
    end

    private
    
    def method_missing(method, *arguments, &block)
      @xml.__send__(method, *arguments, &block)
    end
  end
end