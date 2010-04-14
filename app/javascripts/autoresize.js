function activateResize(element) {
  Event.observe(element, 'keyup', function() {
    updateSize(element)
  });
  updateSize(element)
}

function updateSize(element) {
  var el = $(element);
  //if scrollbars appear, make it bigger, unless it's bigger then the user's browser area.
  //if(Element.getHeight(element) < el.scrollHeight && Element.getHeight(element) < document.viewport.getHeight()) {
  if(el.clientHeight < el.scrollHeight && Element.getHeight(element) < document.viewport.getHeight()) {
    el.style.height = el.getHeight()+15+'px';
    if(el.clientHeight < el.scrollHeight) {
      window.setTimeout("updateSize('"+element+"')",5);
    }               
  }
}