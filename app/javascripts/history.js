// When the URL is like /something#!/route/to/something, then we redirect to /route/to/something
var route = window.location.hash.split("#!")[1]
if(route) {
  window.location = unescape(route)
}

pushHistoryState = function(route) {
  if (window.history && window.history.pushState) {
    window.history.pushState({path: route}, "Teambox", route)
  } else {
    window.location.hash = "!" + escape(route)
  }
}
