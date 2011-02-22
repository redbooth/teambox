document.on('ajax:success', 'a.invitation-destroy', function(e,link) {
	link.up('.invitation').fade()
})

document.on('click','#invitation_select_language', function(e) {
  e.element().replace($("all_locales").innerHTML)
  $('all_locales').remove()
})
