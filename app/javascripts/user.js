User = {
  current_user_login: function() {
    var meta = $$('meta[name="current-username"]').first()
    return meta ? meta.readAttribute('content') : null
  }
}