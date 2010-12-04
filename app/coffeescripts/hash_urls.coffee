# When the URL is like /something#!/route/to/something, then we redirect to /route/to/something

# Redirect if there's a bang hash
route = window.location.hash.split("#!")[1]
window.location = route if route

# Used by AJAX links to set an absolute path with the URL's hash
window.addHashForAjaxLink = (route) ->
  window.location.hash = "!" + route
