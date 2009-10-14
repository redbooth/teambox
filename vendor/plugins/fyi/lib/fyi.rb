module FyiHelper

  def tooltip(name, html, options={})
    "<div id='#{name}_fyi' class='fyi'>#{html}</div>"
  end
  
end