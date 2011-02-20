document.on('click', '#upload_file_button', function(e, button) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    $('new_upload').show()
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
  if (input.value != '') input.insert({ after: newInput })
})

document.on('click', '.uploads .upload .header', function(e, el) {
  e.stop()
  var reference = el.up('.upload').down('.reference')
  if (reference.visible()) {
    reference.hide()
  } else {
    $$('.uploads .upload .reference').invoke('hide')
    reference.show()
  }
})
