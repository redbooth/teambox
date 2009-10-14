module Tabnav
  class Nav
    attr_accessor :tabs, :html, :name

    def initialize(name, opts={})
      @name = name || :main
      @tabs = []
      @html = opts[:html] || {}
      @html[:id] ||= name.to_s.underscore
      @html[:class] ||= @html[:id]
    end
  end
end  