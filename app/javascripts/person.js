hideBySelector('#people .edit_person')

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

document.on('ajax:success', '#people form', function(e) {
  this.up('.person').replace(e.memo.responseText)
})

document.on('change', '#other_projects select', function(e) {
  var value = this.getValue(), loading = $('people_project_load')
  if (value) {
    this.up('form').request({
      onComplete: function(e) {
        loading.hide()
        $('sidebar_people').update(e.responseText)
      }
    })
    loading.show()
  } else {
    $('sidebar_people').update('')
    loading.hide()
  }
})

document.on('click', '#sidebar_people a[href]', function(e) {
  e.preventDefault()
  var login = this.readAttribute('href').split('/').last()
  $('invitation_user_or_email').setValue(login).focus()
})
