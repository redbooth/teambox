module Tabnav
  class Tab
    include Highlightable
    include Disableable
    attr_accessor :link, :name, :html

    def initialize(opts={})
      @name = opts[:name] 
      @link = opts[:link] || {}
      
      # wrap highlights into an array if only one hash has been passed
      opts[:highlights] = [opts[:highlights]] if opts[:highlights].kind_of?(Hash)
      self.highlights = opts[:highlights] || []
      self.disabled_if opts[:disabled_if]
      @html = opts[:html] || {} 
      @html[:title] = opts[:title]

      yield(self) if block_given?

      self.highlights << @link if link? # it does highlight on itself
      raise ArgumentError, 'you must provide a name' unless @name
    end

    def title
      @html[:title]
    end
    
    def title=(new_title)
      @html[:title]=new_title
    end
    
    def li_class; @html[:li_class]; end
    
    def li_class=(li)
      @html[:li_class] = li
    end
    
    def li_end
      @html[:li_end]
    end
    
    def li_end=(li)
      @html[:li_end] = li
    end
        
    def links_to(l)
       @link = l
    end

    def named(n)
      @name = n
    end

    def titled(t)
      @html[:title] = t
    end
    
    def link?
      @link && !@link.empty?
    end
  end
end