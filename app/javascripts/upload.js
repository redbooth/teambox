document.on('click', '.index_uploads #column .add_button', function(e, button) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    button.next('form').show()
    button.hide()
  }
})

String.prototype.incrementLastNumber = function() {
  var i = 0, matches = this.match(/\d+/g)
  matches.push(parseInt(matches.pop()) + 1)
  return this.gsub(/\d+/, function(m) { return matches[i++] })
}

document.on('change', '.upload_area input[type=file]', function(e, input) {
  var newInput = new Element('input', {
    type: 'file',
    name: input.name.incrementLastNumber()
  })
  
  input.insert({ after: newInput })
})
