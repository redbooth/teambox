document.on('dom:loaded', function() {
  if (!window.Modernizr) return
  
  if (!Modernizr.input.placeholder) {
    var selector = 'input[placeholder], textarea[placeholder]'
    
    function emulatePlaceholder(field) {
      var title = field.readAttribute('placeholder'),
          init = function() {
            if (field.getValue().empty()) field.setValue(title).addClassName('placeholder')
          }

      init()

      field.observe('blur', init).observe('focus', function() {
        if (this.getValue() === title) this.setValue('').removeClassName('placeholder')
      })
    }
    
    // setup existing fields
    $$(selector).each(emulatePlaceholder)
    
    // observe form submits and clear emulated placeholder values
    $(document.body).on('submit', 'form:has(' + selector + ')', function(e, form) {
      form.select(selector).each(function(field) {
        if (field.getValue() == field.readAttribute('placeholder')) field.setValue('')
      })
    })
    
    // observe new forms inserted into document and setup fields inside
    document.on('DOMNodeInserted', 'form', function(e) {
      if (e.element().match('form')) e.element().select(selector).each(emulatePlaceholder)
    })
  }

  if (!Modernizr.input.autofocus) {
    var input = $(document.body).down('input[autofocus]')
    if (input) input.activate()
  }
})
