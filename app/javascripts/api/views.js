document.on("dom:loaded", function() {
  //Store.clear()
  if (location.pathname.match("static/activities")) Load.Activities()
  if (location.pathname.match("static/tasks")) Load.Tasks()
})

document.on("click", "a#clear_store", function(e) {
  Store.clear()
  alert("Storage cleared!")
  e.stop()
})