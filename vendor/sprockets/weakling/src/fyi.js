document.on("dom:loaded", function() {
  $$('.fyi').invoke('hide')
})

Event.addBehavior({
  'input:focusin': function(e) {
    var tooltip = this.next('.fyi')
    if (tooltip) {
      tooltip.show()
      var offset = this.cumulativeOffset()
      tooltip.setStyle({
        left: offset.left + this.getLayout().get('border-box-width') + 10 + 'px',
        top: offset.top + 'px'
      })
    }
  },
  'input:focusout': function(e){
    var tooltip = this.next('.fyi')
    if (tooltip) tooltip.hide()
  }
})
