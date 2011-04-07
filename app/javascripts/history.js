// IMPORTANT: pushState is disabled, we want hashbangs for now
// When the URL is like /something#!/route/to/something, then we redirect to /route/to/something
var route = window.location.hash.split("#!")[1]

if(false && route) {
  window.location = unescape(route)
}

pushHistoryState = function(route) {
  if (false && window.history && window.history.pushState) {
    window.history.pushState({path: route}, "Teambox", route)
  } else {
    window.location.hash = "!" + escape(route)
  }
}
