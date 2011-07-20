document.on('ajax:success', '.teambox_data a[data-method="delete"]', function(e, link) {
  link.up('.teambox_data').remove();
})
