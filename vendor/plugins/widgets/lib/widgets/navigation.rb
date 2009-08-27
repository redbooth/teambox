module Widgets 
  class Navigation
    attr_accessor :name, :items, :html, :separator
    include CssTemplate
    
    def initialize(name, opts={})
      @name = name
      @items = []
      @generate_css = opts[:generate_css] || false
      @html = opts[:html] || {} # setup default html options
      @html[:id] ||= "#{@name}_navigation"
      @html[:class] ||= @html[:id]
      @separator = opts[:separator] ||= '&nbsp;|'
    end
    
    def add_item opts={}
      @items ||= []
      @items << NavigationItem.new(opts)
    end
  
  end
end