document.on('dom:loaded', function() {
  if (!window.Modernizr) return
  
  if (!Modernizr.input.placeholder) {
    $$('input[placeholder]').each(function(field) {
      field.addClassName('placeholder')
      var title = field.readAttribute('placeholder')
      if (field.getValue().empty()) field.setValue(title)

      field.observe('blur', function() {
        if (this.getValue().empty()) field.setValue(title).removeClassName('focused')
      }).observe('focus', function() {
        if (this.getValue() === title) field.setValue('').addClassName('focused')
      })
    })
  }

  if (!Modernizr.input.autofocus) {
    var input = $(document.body).down('input[autofocus]')
    if (input) input.activate()
  }
})
