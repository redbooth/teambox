document.on('click', '.index_uploads #column .add_button', function(e, button) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    button.next('form').show()
    button.hide()
  }
})

document.on('change', '.upload_area input[type=file]', function(e, input) {
  var newInput = new Element('input', {
    type: 'file',
    name: input.name.sub(/\d+/, function(m) { return parseInt(m[0]) + 1 })
  })
  
  input.insert({ after: newInput })
})
