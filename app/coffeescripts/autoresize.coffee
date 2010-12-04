# Typing on textareas will resize the box to fit the text, but not outside the viewport

Element.addMethods
  resizeToText: (area, force) ->
    area = $(area)
    if (area.scrollHeight > area.clientHeight)
      wanted = area.getHeight() + (area.scrollHeight - area.clientHeight) + 15
      available = document.viewport.getHeight() - area.viewportOffset().top - 60
      possible = if force then wanted else Math.min(wanted, available)
      area.setStyle height: possible + 'px'


document.on 'keyup', 'textarea', (e, area) ->
  if e.keyCode == Event.KEY_RETURN
    # resize as soon as the js interpreter is idle
    Element.resizeToText.defer(area, false)
  else
    # resize once the user stops typing for 100ms
    resizeLimited = Element.resizeToText.debounce(100)
    resizeLimited(area, false)

document.on 'facebox:opened', ->
  $$('.facebox-content textarea').each (element) ->
    element.resizeToText(false)
