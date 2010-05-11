;(function() {
  var selector = '.fyi',
      head = document.getElementsByTagName('head')[0],
      style = document.createElement('style')

  style.appendChild(document.createTextNode(selector + ' { display:none }'))
  head.appendChild(style)

  Event.addBehavior({
    'input:focusin': function(e) {
      var tooltip = this.next(selector)
      if (tooltip) {
        tooltip.setStyle({ display: 'block' })
        var offset = this.cumulativeOffset()
        tooltip.setStyle({
          left: offset.left + this.getLayout().get('border-box-width') + 10 + 'px',
          top: offset.top + 'px'
        })
      }
    },
    'input:focusout': function(e){
      var tooltip = this.next(selector)
      if (tooltip) tooltip.hide()
    }
  })
})()
