function activateResize(element) {
  Event.observe(element, 'keyup', function() {
    updateSize(element)
  });
  updateSize(element)
}

function updateSize(element) {
  //if scrollbars appear, make it bigger, unless it's bigger then the user's browser area.
  if(Element.getHeight(element)<$(element).scrollHeight&&Element.getHeight(element)<document.viewport.getHeight()) {
    $(element).style.height = $(element).getHeight()+15+'px'
    if(Element.getHeight(element)<$(element).scrollHeight) {
      window.setTimeout("updateSize('"+element+"')",5)
    }               
  }
}