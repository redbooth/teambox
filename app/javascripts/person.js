hideBySelector('#people .edit_person')

document.on('click', '#people a[href$="#destroy"]', function(e, link) {
  e.preventDefault()
  if (confirm(link.readAttribute('data-confirm'))) {
    new Ajax.Request(link.readAttribute('href'), {
      method: 'delete',
      onSuccess: function() {
        link.up('.person').remove()
      }
    })
  }
})

document.on('click', '#people a[href="#edit"]', function(e) {
  e.preventDefault()
  var parent = this.up('.person')
  parent.down('.edit_person').setStyle({ display:'block' })
  parent.down('.person_header').hide()
})

document.on('click', '#people form a[href="#cancel"]', function(e) {
  e.preventDefault()
  var parent = this.up('.person')
  parent.down('.edit_person').hide()
  parent.down('.person_header').show()
})

document.on('submit:success', '#people form', function(e) {
  this.up('.person').replace(e.memo.responseText)
})
