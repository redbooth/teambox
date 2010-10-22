// When the URL is like /something#!/route/to/something, then we redirect to /route/to/something
var route = window.location.hash.split("#!")[1]
if(route) {
  window.location = route
}

addHashForAjaxLink = function(route) {
  window.location.hash = "!" + route
}
