document.on("dom:loaded", function() {
  if(my_user.splash_screen) {
    $(document.body).insert({
      after: "<div id='splash'><a id='hide_splash' href='/disable_splash'><img src='/images/splash.jpg'/></a></div>"
    })
    $('container').hide()
    
    document.on("click", "#hide_splash", function(e,link) {
      Event.stop(e)
      new Ajax.Request(link.href, { method: 'get' })
      $('container').show()
      $('splash').fade()
      window.location.hash = ""
    })
  }
})
