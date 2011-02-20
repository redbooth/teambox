// Automatic pagination when .show_more_button is 350px over the bottom
document.on('scroll', function() {
  var link = $$('.show_more_button a.activity_paginate_link').last();
  if(!link) return;

  var view_height = document.viewport.getHeight();
  var link_height = link.viewportOffset().top;
  var refresh_fn = link.onclick;
  if (!refresh_fn) return; // RAILS3 fix this

  if( (link_height < view_height - 350) && !refresh_fn.called) {
    refresh_fn.called = true;
    refresh_fn();
  }
})

document.on('ajax:create', '.activity_paginate_link', function(e, form) {
  $('activity_paginate_link').hide()
  $('activity_paginate_loading').show()
})
