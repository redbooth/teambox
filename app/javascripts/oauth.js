document.on('ajax:success', '.client_token a.revoke', function(e, link) {
  link.up('.client_token').remove();
})

document.on('click', '#oauth_authorize_form .allow', function(e, link) {
  var form = link.up('form')
  var authorize = form.down('input[name=authorize]')
  authorize.value = '1'
  form.submit();
})

document.on('click', '#oauth_authorize_form .deny', function(e, link) {
  var form = link.up('form')
  var authorize = form.down('input[name=authorize]')
  authorize.value = '0'
  form.submit();
})
