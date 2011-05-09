document.on('ajax:success', '.client_token a.revoke', function(e, link) {
  link.up('.client_token').remove();
})
