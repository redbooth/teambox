document.on('dom:loaded', function() {
  if (!window.Modernizr) return
  
  if (!Modernizr.input.placeholder) {
    var selector = 'input[placeholder], textarea[placeholder]'
    
    function emulatePlaceholder(input) {
      var val = input.getValue(), text = input.readAttribute('placeholder')
      if (val.empty() || val === text)
        input.setValue(text).addClassName('placeholder')
    }
    
    document.on('focusin', selector, function(e, input) {
      if (input.getValue() === input.readAttribute('placeholder'))
        input.setValue('').removeClassName('placeholder')
    })
    
    document.on('focusout', selector, function(e, input) {
      emulatePlaceholder(input)
    })
    
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
  
  Modernizr.addTest('inputsearch', function() {
    return Modernizr.inputtypes.search
  })
})
