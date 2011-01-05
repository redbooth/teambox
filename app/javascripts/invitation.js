document.on('ajax:success', 'a.invitation-destroy', function(e,link) {
	link.up('.invitation').fade()
})