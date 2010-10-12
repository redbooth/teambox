hideBySelector('#people .edit_person')

document.on('click', '#people a[href="#edit"]', function(e, link) {
  e.preventDefault()
  var parent = link.up('.person')
  parent.down('.edit_person').forceShow()
  parent.down('.person_header').hide()
})

document.on('click', '#people form a[href="#cancel"]', function(e, link) {
  e.preventDefault()
  var parent = link.up('.person')
  parent.down('.edit_person').hide()
  parent.down('.person_header').show()
})

document.on('ajax:success', '#people form', function(e, form) {
  form.up('.person').replace(e.memo.responseText)
})

document.on('change', '#other_projects select', function(e, selectbox) {
  var value = selectbox.getValue(), loading = $('people_project_load')
  if (value) {
    selectbox.up('form').request({
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

document.on('click', '#sidebar_people a[href]', function(e, link) {
  e.preventDefault()
  var login = link.readAttribute('href').split('/').last()
  $('invitation_user_or_email').setValue(login).focus()
})

document.on('ajax:success', '.person a[data-method="delete"]', function(e, link) {
  var parent = link.up('.person')
  parent.remove()
})
