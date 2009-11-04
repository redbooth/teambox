module FyiHelper

  def tooltip(name, html, options={})
    "<div id='#{name}_fyi' class='fyi' style='display:none'>#{html}</div>"
  end
  
end