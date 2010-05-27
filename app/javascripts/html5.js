document.on('dom:loaded', function() {
  if (!window.Modernizr) return
  
  if (!Modernizr.input.placeholder) {
    $$('input[placeholder], textarea[placeholder]').each(function(field) {
      field.addClassName('placeholder')
      var title = field.readAttribute('placeholder')
      if (field.getValue().empty()) field.setValue(title)

      field.observe('blur', function() {
        if (this.getValue().empty()) field.setValue(title).addClassName('placeholder')
      }).observe('focus', function() {
        if (this.getValue() === title) field.setValue('').removeClassName('placeholder')
      })
    })
  }

  if (!Modernizr.input.autofocus) {
    var input = $(document.body).down('input[autofocus]')
    if (input) input.activate()
  }
})
