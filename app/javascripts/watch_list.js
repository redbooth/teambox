document.on('click', '.index_watchers .remove a', function(e, link) {
  e.stop()
  var container = link.up('.watch')

  new Ajax.Request(link.href, {
    method: 'post',
    asynchronous: true,
    evalScripts: true,
    onLoading: function() {
      link.fade()
    },
    onSuccess: function() {
      container.fade()
    },
    onFailure: function() {
      link.show()
    }
  })
})