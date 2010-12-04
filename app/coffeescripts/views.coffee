document.on "dom:loaded", ->
  Store.clear()
  Load.Activities() if location.pathname.match("static/activities")
  Load.Tasks() if location.pathname.match("static/tasks")

document.on "click", "a#clear_store", (e) ->
  Store.clear()
  alert "Storage cleared!"
  e.stop()
