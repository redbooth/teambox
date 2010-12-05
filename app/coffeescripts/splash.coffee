# Splash screen: shows an introductory image on your first login, and hides it when clicking it

document.on "dom:loaded", ->
  return unless my_user?

  if my_user.splash_screen
    $(document.body).insert
      after: "<div id='splash'><a id='hide_splash' href='/disable_splash'><img src='/images/splash.jpg'/></a></div>"

    $('container').hide()
    
    document.on "click", "#hide_splash", (e,link) ->
      e.stop()
      new Ajax.Request link.href, method: 'get'
      $('container').show()
      $('splash').fade()
      window.location.hash = ""
