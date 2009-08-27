module Widgets
  class NavigationItem
    include Highlightable
    
    attr_accessor :name, :link, :html
    
    def initialize(opts={})
      @name = opts[:name] 
      @link = opts[:link] || {}
      @html = opts[:html] || {} 
      @html[:title] = opts[:title] 
     
      yield(self) if block_given?
      
      self.highlights << @link if link? # it does highlight on itself
      raise ArgumentError, 'you must provide a name' unless @name
    end
    
    # more idiomatic ways to set tab properties
    def links_to(l); @link = l; end
    def named(n); @name = n; end
    def titled(t); @html[:title] = t; end 
       
    def link?
      @link && !@link.empty?
    end
         
  end
end