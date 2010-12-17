module TabnavHelper  
  protected 

  def tabnav(name, &block)
    html = capture { render "shared/#{name}" }
    if block_given?
      options = {:id => @_tabnav.html[:id] + '_content', :class => @_tabnav.html[:class] + '_content'}
      html << tag('div', options, true)
      html << capture(&block)
      html << '</div>' 
      out html
      nil # avoid duplication if called with <%= %>
    else
      html
    end
  end

  def render_tabnav(name, opts={}, &proc)
    raise ArgumentError, "Missing name parameter in tabnav call" unless name
    raise ArgumentError, "Missing block in tabnav call" unless block_given?
    @_tabnav = Tabnav::Nav.new(name, opts)
    @_binding = proc.binding

    instance_eval(&proc) 
    out tag('div',@_tabnav.html ,true)
      render_tabnav_tabs 
    out "</div>"
    nil
  end 

  def add_tab(options = {}, &block) 
    raise 'Cannot call add_tab outside of a render_tabnav block' unless @_tabnav
    @_tabnav.tabs << Tabnav::Tab.new(options, &block)
    nil
  end
  
  def controller_names
    files = Dir.entries(File.join(Rails.root, 'app/controllers'))
    controllers = files.select {|x| x.match '_controller.rb'}
    controllers.map {|x| x.sub '_controller.rb', ''}.sort
  end

  private

  def render_tabnav_tabs
    out tag('ul', {} , true)

    @_tabnav.tabs.each do |tab|

      if tab.disabled?
        tab.html[:class] ||= ""
        tab.html[:class] += ' disabled'
      elsif tab.highlighted?(params)
        tab.html[:class] ||= ""
        tab.html[:class] += ' active'
      end

      li_options = {} 
      
      if tab.html[:id]
        li_options[:id] = tab.html[:id] + '_container'
      end
      
      if tab.html[:li_class]      
        li_options[:class] = tab.html[:li_class] 
      end
      tab.html.delete(:li_class)
        
      if tab.html[:li_end]
        tag_end = tab.html[:li_end]
      end
      tab.html.delete(:li_end)

      li_tab(tab,li_options,tag_end)
    end 
    out '</ul>'
  end  

  def li_tab(tab,li_options,tag_end)
    out tag('li', li_options, true)

    if tab.disabled? || (tab.link.empty?)
      out content_tag('span', tab.name, tab.html) 
    elsif !tab.link.empty?
      out link_to(tab.name, tab.link, tab.html)
    else
      raise "Ground Control to Major Tom..."
    end 

    out "#{tag_end} </li>"
  end

  def out(string)
    concat string.html_safe
  end
end