document.on('ajax:success', '.actions a.delete', function(e, link) {
  console.log('Success!!')
  link.up('.notification').fade()
})

document.on('ajax:success', '.actions a.toggle', function(e, link) {
  var data = link.text
  var alt  = link.readAttribute('data-alt')

  link.update(alt)
  link.writeAttribute('data-alt', data)
})

document.on('ajax:before', '.actions a', function(e, link) {
  // do something to avoid double click
  link.up('.action').hide()
})

document.on('ajax:complete', '.actions a', function(e, link) {
  link.up('.action').show()
})

document.on('click', '#notifications input#select-all', function(e, input) {
  var checked = input.checked

  $$('.actions input[type=checkbox]').each( function(checkbox) { 
    checkbox.checked = checked
  })
})