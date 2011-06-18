document.on('click', '#upload_file_button', function(e, button) {
  e.preventDefault();
  $('new_upload').toggle();
});

document.on('click', '#new_folder_button, #new_folder_form a.close', function(e, button) {
  e.preventDefault();
  $('new_folder_form').toggle();
  if ($('new_folder_form').visible()) {
    $('new_folder_form').down('#new_folder_name').focus();
  }
});

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
  if (input.form.hasEmptyFileUploads() == false) input.insert({ after: newInput })
})

document.on('click', '.uploads .upload .header', function(e, el) {
  return;
  e.stop()
  var reference = el.up('.upload').down('.reference')
  if (reference.visible()) {
    reference.hide()
  } else {
    $$('.uploads .upload .reference').invoke('hide')
    reference.show()
  }
})
